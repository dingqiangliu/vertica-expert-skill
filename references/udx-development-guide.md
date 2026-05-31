# Vertica User-Defined Extensions (UDx) Development Guide

This comprehensive guide covers developing User-Defined Extensions (UDxs) in Vertica using C++, Python, Java, and R for creating custom functions, aggregates, and data processing capabilities.

## UDx Overview

User-Defined Extensions (UDxs) allow you to extend Vertica's functionality with custom code. They can be developed in multiple languages and provide high-performance, distributed processing capabilities.

### UDx Types

1. **User-Defined Scalar Functions (UDSFs)**
   - Take single row input, return single value
   - Can be used anywhere native functions are used
   - Languages: C++, Python, Java, R

2. **User-Defined Aggregate Functions (UDAFs)**
   - Process one column of data, return one output column
   - Support distributed aggregation with combine operations
   - Languages: C++ only (for performance)

3. **User-Defined Analytic Functions (UDAnFs)**
   - Similar to UDSFs but can read multiple input rows
   - Support OVER() clause for partitioning
   - Languages: C++, Java

4. **User-Defined Transform Functions (UDTFs)**
   - Operate on table partitions, return zero or more rows
   - Can return entirely new table schemas
   - Languages: C++, Python, Java, R

5. **User-Defined Load (UDL)**
   - Custom data loading components (sources, filters, parsers)
   - Languages: C++, Java, Python

## C++ UDx Development

### Development Environment Setup

```bash
# Required development packages
sudo apt-get install build-essential cmake g++ libboost-dev

# Vertica SDK location (typically)
/opt/vertica/sdk/include/
```

### Basic C++ UDx Structure

```cpp
// Example: Simple scalar function
#include "Vertica.h"
#include <string>

using namespace Vertica;

class StringLength : public ScalarFunction
{
public:
    virtual void setup(ServerInterface &srvInterface) {
        // Initialize resources
    }

    virtual void destroy(ServerInterface &srvInterface) {
        // Clean up resources
    }

    virtual void processBlock(ServerInterface &srvInterface,
                            BlockReader &argReader,
                            BlockWriter &resWriter)
    {
        while (argReader.getNumNonNull())
        {
            // Get input string
            vstring &inputStr = argReader.getStringRef(0);
            
            // Calculate length
            int32 length = inputStr.length();
            
            // Write result
            resWriter.setInt(length);
            
            argReader.next();
            resWriter.next();
        }
    }
};

// Factory class
class StringLengthFactory : public ScalarFunctionFactory
{
public:
    virtual void getPrototype(ServerInterface &srvInterface,
                             ColumnTypes &argTypes,
                             ColumnTypes &returnType)
    {
        argTypes.addVarchar();  // Input: VARCHAR
        returnType.addInt();     // Output: INTEGER
    }

    virtual ScalarFunction *createScalarFunction(ServerInterface &srvInterface)
    {
        return new StringLength();
    }

    virtual void getReturnType(ServerInterface &srvInterface,
                              const SizedColumnTypes &inputTypes,
                              SizedColumnTypes &outputTypes)
    {
        outputTypes.addInt(inputTypes.getColumnName(0));
    }
};

// Register the function
RegisterScalarFunction<StringLengthFactory> stringLengthReg("string_length");
```

### Advanced C++ UDAF Example

```cpp
// Weighted Average Aggregate Function
#include "Vertica.h"
#include <map>

using namespace Vertica;

class WeightedAverage : public AggregateFunction
{
public:
    // Intermediate state for aggregation
    struct WeightedState
    {
        double sum_product;
        double sum_weights;
        
        WeightedState() : sum_product(0.0), sum_weights(0.0) {}
    };

    virtual void setup(ServerInterface &srvInterface) {
        // Initialize per-instance state
    }

    virtual void destroy(ServerInterface &srvInterface) {
        // Clean up per-instance state
    }

    virtual void initialize(ServerInterface &srvInterface,
                           BlockWriter &resWriter)
    {
        WeightedState *state = (WeightedState*)resWriter.getUserData();
        new (state) WeightedState();  // placement new
    }

    virtual void aggregate(ServerInterface &srvInterface,
                          BlockReader &argReader,
                          BlockWriter &resWriter)
    {
        WeightedState *state = (WeightedState*)resWriter.getUserData();
        
        while (argReader.getNumNonNull())
        {
            double value = argReader.getFloatRef(0);
            double weight = argReader.getFloatRef(1);
            
            if (!argReader.isNull(0) && !argReader.isNull(1) && weight != 0.0)
            {
                state->sum_product += value * weight;
                state->sum_weights += weight;
            }
            
            argReader.next();
        }
    }

    virtual void combine(ServerInterface &srvInterface,
                        BlockReader &interReader,
                        BlockWriter &resWriter)
    {
        // Combine intermediate results from different nodes
        WeightedState *state1 = (WeightedState*)resWriter.getUserData();
        WeightedState *state2 = (WeightedState*)interReader.getUserData();
        
        state1->sum_product += state2->sum_product;
        state1->sum_weights += state2->sum_weights;
    }

    virtual void terminate(ServerInterface &srvInterface,
                          BlockReader &interReader,
                          BlockWriter &resWriter)
    {
        WeightedState *state = (WeightedState*)interReader.getUserData();
        
        if (state->sum_weights > 0.0)
        {
            resWriter.setFloat(state->sum_product / state->sum_weights);
        }
        else
        {
            resWriter.setFloat(0.0);
        }
        
        resWriter.next();
    }
};

// Factory for weighted average
class WeightedAverageFactory : public AggregateFunctionFactory
{
public:
    virtual void getPrototype(ServerInterface &srvInterface,
                             ColumnTypes &argTypes,
                             ColumnTypes &returnType)
    {
        argTypes.addFloat();  // value
        argTypes.addFloat();  // weight
        returnType.addFloat(); // weighted average
    }

    virtual void getIntermediateType(ServerInterface &srvInterface,
                                   const SizedColumnTypes &inputTypes,
                                   SizedColumnTypes &outputTypes)
    {
        outputTypes.addVarchar(sizeof(WeightedAverage::WeightedState), "state");
    }

    virtual void getReturnType(ServerInterface &srvInterface,
                              const SizedColumnTypes &inputTypes,
                              SizedColumnTypes &outputTypes)
    {
        outputTypes.addFloat(inputTypes.getColumnName(0));
    }

    virtual AggregateFunction *createAggregateFunction(ServerInterface &srvInterface)
    {
        return new WeightedAverage();
    }
};

RegisterAggregateFunction<WeightedAverageFactory> weightedAvgReg("weighted_average");
```

### C++ UDTF Example

```cpp
// Element Counter Transform Function
#include "Vertica.h"
#include <map>
#include <vector>

using namespace Vertica;

class ElementCounter : public TransformFunction
{
public:
    virtual void setup(ServerInterface &srvInterface) {
        // Initialize
    }

    virtual void destroy(ServerInterface &srvInterface) {
        // Cleanup
    }

    virtual void processPartition(ServerInterface &srvInterface,
                                PartitionReader &inputReader,
                                PartitionWriter &outputWriter)
    {
        std::map<std::string, int64> element_counts;
        
        // Count elements
        while (inputReader.getNumNonNull())
        {
            vstring &element = inputReader.getStringRef(0);
            element_counts[element.c_str()]++;
            inputReader.next();
        }
        
        // Output results
        for (const auto &pair : element_counts)
        {
            outputWriter.getStringRef(0).copy(pair.first.c_str());
            outputWriter.setInt(1, pair.second);
            outputWriter.next();
        }
    }
};

class ElementCounterFactory : public TransformFunctionFactory
{
public:
    virtual void getPrototype(ServerInterface &srvInterface,
                             ColumnTypes &inputTypes,
                             ColumnTypes &outputTypes)
    {
        inputTypes.addVarchar();  // Input: element
        outputTypes.addVarchar(); // Output: element
        outputTypes.addInt();      // Output: count
    }

    virtual TransformFunction *createTransformFunction(ServerInterface &srvInterface)
    {
        return new ElementCounter();
    }
};

RegisterTransformFunction<ElementCounterFactory> elementCounterReg("element_counter");
```

## Python UDx Development

### Basic Python UDSF

```python
# string_utils.py
import vertica_sdk

class StringReverse(vertica_sdk.ScalarFunction):
    def __init__(self):
        pass
    
    def setup(self, srv):
        pass
    
    def processBlock(self, srv, arg_reader, res_writer):
        while arg_reader.getNumNonNull():
            # Get input string
            input_str = arg_reader.getStringRef(0)
            
            # Reverse the string
            reversed_str = input_str[::-1]
            
            # Write result
            res_writer.getStringRef(0).copyFrom(reversed_str)
            
            arg_reader.next()
            res_writer.next()
        
        return True
    
    def destroy(self, srv):
        pass

class StringReverseFactory(vertica_sdk.ScalarFunctionFactory):
    def createScalarFunction(self, srv):
        return StringReverse()
    
    def getPrototype(self, srv, arg_types, return_type):
        arg_types.addVarchar()   # Input
        return_type.addVarchar() # Output
    
    def getReturnType(self, srv, input_types, output_types):
        output_types.addVarchar(input_types.getColumnName(0), 65000)

# Register the function
vertica_sdk.register(StringReverseFactory())
```

### Python UDTF Example

```python
# data_transformer.py
import vertica_sdk
import json

class JsonParser(vertica_sdk.TransformFunction):
    def __init__(self):
        self.json_data = {}
    
    def setup(self, srv):
        pass
    
    def processPartition(self, srv, input_reader, output_writer):
        while input_reader.getNumNonNull():
            # Get JSON string
            json_str = input_reader.getStringRef(0)
            
            try:
                # Parse JSON
                data = json.loads(json_str)
                
                # Extract fields
                if 'name' in data:
                    output_writer.getStringRef(0).copyFrom(data['name'])
                else:
                    output_writer.setNull(0)
                
                if 'age' in data:
                    output_writer.setInt(1, int(data['age']))
                else:
                    output_writer.setNull(1)
                
                if 'email' in data:
                    output_writer.getStringRef(2).copyFrom(data['email'])
                else:
                    output_writer.setNull(2)
                
                output_writer.next()
                
            except json.JSONDecodeError as e:
                srv.log(f"JSON parse error: {e}")
                # Output nulls for invalid JSON
                output_writer.setNull(0)
                output_writer.setNull(1)
                output_writer.setNull(2)
                output_writer.next()
            
            input_reader.next()
        
        return True
    
    def destroy(self, srv):
        pass

class JsonParserFactory(vertica_sdk.TransformFunctionFactory):
    def createTransformFunction(self, srv):
        return JsonParser()
    
    def getPrototype(self, srv, input_types, output_types):
        input_types.addLongVarchar()  # JSON input
        output_types.addVarchar()     # name
        output_types.addInt()         # age
        output_types.addVarchar()     # email
    
    def getReturnType(self, srv, input_types, output_types):
        output_types.addVarchar("name", 100)
        output_types.addInt("age")
        output_types.addVarchar("email", 255)

vertica_sdk.register(JsonParserFactory())
```

## Java UDx Development

### Java UDSF Example

```java
// MathUtils.java
import com.vertica.sdk.*;

public class MathUtils extends ScalarFunction {
    
    @Override
    public void setup(ServerInterface srv) {
        // Initialize
    }
    
    @Override
    public void processBlock(ServerInterface srv, BlockReader argReader, BlockWriter resWriter) {
        while (argReader.getNumNonNull()) {
            // Calculate square root
            double input = argReader.getFloatRef(0);
            double result = Math.sqrt(input);
            
            resWriter.setFloat(0, result);
            
            argReader.next();
            resWriter.next();
        }
    }
    
    @Override
    public void destroy(ServerInterface srv) {
        // Cleanup
    }
}

public class MathUtilsFactory extends ScalarFunctionFactory {
    
    @Override
    public void getPrototype(ServerInterface srv, ColumnTypes argTypes, ColumnTypes returnType) {
        argTypes.addFloat();   // Input: double
        returnType.addFloat(); // Output: double
    }
    
    @Override
    public ScalarFunction createScalarFunction(ServerInterface srv) {
        return new MathUtils();
    }
    
    @Override
    public void getReturnType(ServerInterface srv, SizedColumnTypes inputTypes, SizedColumnTypes outputTypes) {
        outputTypes.addFloat(inputTypes.getColumnName(0));
    }
}

// Register in static block
static {
    try {
        ServerInterface srv = new ServerInterface();
        new MathUtilsFactory().register(srv, "sqrt");
    } catch (Exception e) {
        e.printStackTrace();
    }
}
```

## UDx Registration and Deployment

### C++ UDx Compilation

```bash
# Compile C++ UDx
vbuildudx --cpp my_function.cpp --output my_function.so

# Or manually
g++ -fPIC -shared -I$VERTICA_SDK_INCLUDE my_function.cpp -o my_function.so
```

### Python UDx Deployment

```bash
# Copy Python file to Vertica
scp string_utils.py dbadmin@vertica_host:/home/dbadmin/

# Install in Vertica
vsql -c "CREATE OR REPLACE LIBRARY string_utils AS '/home/dbadmin/string_utils.py' LANGUAGE 'Python';"
```

### Function Creation

```sql
-- C++ Scalar Function
CREATE OR REPLACE FUNCTION string_length AS '/path/to/string_length.so'
LANGUAGE 'C++';

-- Python Scalar Function
CREATE OR REPLACE FUNCTION reverse_string AS '/path/to/string_utils.py'
LANGUAGE 'Python';

-- Aggregate Function
CREATE OR REPLACE FUNCTION weighted_average AS '/path/to/weighted_avg.so'
LANGUAGE 'C++';

-- Transform Function
CREATE OR REPLACE FUNCTION parse_json AS '/path/to/json_parser.py'
LANGUAGE 'Python';
```

## Usage Examples

### Scalar Functions

```sql
-- Using custom string function
SELECT reverse_string(product_name) as reversed_name
FROM products
WHERE LENGTH(product_name) > 10;

-- Using mathematical function
SELECT sqrt(quantity * unit_price) as sqrt_total
FROM order_details
WHERE quantity > 0;
```

### Aggregate Functions

```sql
-- Weighted average by category
SELECT
    category_id,
    weighted_average(sales_amount, customer_importance) as weighted_sales
FROM sales_data
GROUP BY category_id;

-- Complex aggregation
SELECT
    region,
    weighted_average(profit, revenue) as profit_efficiency
FROM financial_data
WHERE year = 2024
GROUP BY region
ORDER BY profit_efficiency DESC;
```

### Transform Functions

```sql
-- Parse JSON data
SELECT *
FROM parse_json(
    ON (SELECT json_column FROM raw_data)
    COLUMNS (name VARCHAR(100), age INT, email VARCHAR(255))
);

-- Count elements
SELECT *
FROM element_counter(
    ON (SELECT tags FROM products)
    COLUMNS (tag VARCHAR(50), tag_count BIGINT)
);
```

## Performance Considerations

### 1. Language Selection
- **C++**: Best performance, unfenced mode available
- **Python**: Good for complex logic, always fenced
- **Java**: Enterprise integration, always fenced
- **R**: Statistical computing, always fenced

### 2. Memory Management

```cpp
// C++ memory management
virtual void setup(ServerInterface &srvInterface) {
    // Pre-allocate buffers if known size
    buffer.reserve(1000);
}

virtual void destroy(ServerInterface &srvInterface) {
    // Explicit cleanup
    buffer.clear();
    buffer.shrink_to_fit();
}
```

### 3. Error Handling

```python
# Python error handling
def processBlock(self, srv, arg_reader, res_writer):
    try:
        while arg_reader.getNumNonNull():
            # Process data
            pass
    except Exception as e:
        srv.log(f"Error in processBlock: {e}")
        raise UdfException(f"Processing failed: {e}")
```

## Best Practices

### 1. Development Process
1. **Start with Python** for rapid prototyping
2. **Move to C++** for performance-critical functions
3. **Test thoroughly** with various data types and sizes
4. **Handle NULLs properly** in all functions
5. **Log appropriately** for debugging

### 2. Performance Optimization
- Use intermediate aggregates for UDAFs
- Minimize memory allocations
- Handle NULL values efficiently
- Consider data distribution patterns
- Test with realistic data volumes

### 3. Security Considerations
- Validate input data
- Handle exceptions gracefully
- Avoid buffer overflows in C++
- Use parameterized queries when accessing database
- Follow least privilege principle

### 4. Testing Strategy

```sql
-- Test with various data types
SELECT my_function(column1) FROM test_table;

-- Test with NULL values
SELECT my_function(NULL);

-- Test performance with large datasets
EXPLAIN SELECT my_function(large_column) FROM big_table;

-- Monitor resource usage
SELECT * FROM user_defined_functions_usage;
```

This comprehensive guide provides everything needed to develop high-performance UDxs in Vertica for extending database functionality beyond standard SQL capabilities.