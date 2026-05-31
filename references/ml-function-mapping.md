# Machine Learning Function Mapping

This guide provides quick reference mappings for machine learning functions across different database systems and their Vertica equivalents.

## Overview

When migrating machine learning workflows from other databases to Vertica, this reference helps identify equivalent functions and approaches for common ML tasks.

## General ML Workflow Mapping

### Data Preparation

| Task | Python (scikit-learn) | R | Vertica SQL | Notes |
|------|----------------------|---|-------------|-------|
| Data scaling | `StandardScaler()` | `scale()` | `NORMALIZE()` | Vertica provides in-database normalization |
| One-hot encoding | `OneHotEncoder()` | `model.matrix()` | `ONE_HOT_ENCODER()` | Vertica's function works directly on tables |
| Label encoding | `LabelEncoder()` | `as.factor()` | `LABEL_ENCODER()` | Convert categories to numeric labels |
| Missing value imputation | `SimpleImputer()` | `na.omit()` or `impute()` | `IMPUTE()` | Various strategies: mean, median, mode |
| Train/test split | `train_test_split()` | `sample()` | `SAMPLE()` clause | Use WHERE clause with SAMPLE for filtering |

### Regression Algorithms

| Algorithm | Python (scikit-learn) | R | Vertica SQL | Vertica Function |
|-----------|----------------------|---|-------------|------------------|
| Linear Regression | `LinearRegression()` | `lm()` | `LINEAR_REG()` | In-database linear regression |
| Logistic Regression | `LogisticRegression()` | `glm(family=binomial)` | `LOGISTIC_REG()` | Binary and multiclass classification |
| Random Forest | `RandomForestRegressor()` | `randomForest()` | `RF_REGRESSOR()` | Ensemble regression |
| SVM Regression | `SVR()` | `svm()` | `SVM_REGRESSOR()` | Support Vector Machine regression |
| XGBoost | `XGBRegressor()` | `xgb.train()` | `XGB_REGRESSOR()` | Gradient boosting regression |
| Poisson Regression | `PoissonRegressor()` | `glm(family=poisson)` | `POISSON_REG()` | Count data regression |

### Classification Algorithms

| Algorithm | Python (scikit-learn) | R | Vertica SQL | Vertica Function |
|-----------|----------------------|---|-------------|------------------|
| Logistic Regression | `LogisticRegression()` | `glm(family=binomial)` | `LOGISTIC_REG()` | Primary classification method |
| Random Forest | `RandomForestClassifier()` | `randomForest()` | `RF_CLASSIFIER()` | Ensemble classification |
| SVM Classification | `SVC()` | `svm()` | `SVM_CLASSIFIER()` | Support Vector Machine classification |
| Naive Bayes | `GaussianNB()` | `naiveBayes()` | `NAIVE_BAYES()` | Probabilistic classification |
| XGBoost | `XGBClassifier()` | `xgb.train()` | `XGB_CLASSIFIER()` | Gradient boosting classification |

### Clustering Algorithms

| Algorithm | Python (scikit-learn) | R | Vertica SQL | Vertica Function |
|-----------|----------------------|---|-------------|------------------|
| K-Means | `KMeans()` | `kmeans()` | `KMEANS()` | Standard k-means clustering |
| Bisecting K-Means | Not available | Not available | `BISECTING_KMEANS()` | Vertica-specific hierarchical approach |
| K-Prototypes | `KPrototypes()` (kmodes) | Not standard | `K_PROTOTYPES()` | Mixed data type clustering |

### Time Series Forecasting

| Algorithm | Python (statsmodels) | R | Vertica SQL | Vertica Function |
|-----------|---------------------|---|-------------|------------------|
| AR (AutoRegressive) | `AR()` | `ar()` | `AUTOREGRESSOR()` | Autoregression models |
| MA (Moving Average) | `MovingAverage()` | `ma()` | `MOVING_AVERAGE()` | Moving average models |
| ARIMA | `ARIMA()` | `arima()` | `ARIMA()` | Complete ARIMA implementation |

## Evaluation Metrics

### Regression Metrics

| Metric | Python (scikit-learn) | R | Vertica SQL | Vertica Function |
|--------|----------------------|---|-------------|------------------|
| R-squared | `r2_score()` | `summary(lm_model)$r.squared` | `R2_SCORE()` | Coefficient of determination |
| Mean Squared Error | `mean_squared_error()` | `mean((actual - predicted)^2)` | `MEAN_SQUARED_ERROR()` | MSE calculation |
| Root MSE | `mean_squared_error(squared=False)` | `sqrt(mean((actual - predicted)^2))` | `ROOT_MEAN_SQUARED_ERROR()` | RMSE calculation |
| Mean Absolute Error | `mean_absolute_error()` | `mean(abs(actual - predicted))` | `MEAN_ABSOLUTE_ERROR()` | MAE calculation |
| Comprehensive Evaluation | `regression_metrics()` | Custom functions | `REGRESSION_EVALUATOR()` | Complete regression assessment |

### Classification Metrics

| Metric | Python (scikit-learn) | R | Vertica SQL | Vertica Function |
|--------|----------------------|---|-------------|------------------|
| Accuracy | `accuracy_score()` | `mean(actual == predicted)` | `ACCURACY()` | Classification accuracy |
| Precision | `precision_score()` | Custom calculation | `PRECISION()` | Precision metric |
| Recall | `recall_score()` | Custom calculation | `RECALL()` | Recall (sensitivity) |
| F1 Score | `f1_score()` | Custom calculation | `F1_SCORE()` | F1 harmonic mean |
| Confusion Matrix | `confusion_matrix()` | `table(actual, predicted)` | `CONFUSION_MATRIX()` | Complete confusion matrix |
| ROC AUC | `roc_auc_score()` | `auc()` | `AUC()` | Area under ROC curve |
| ROC Curve | `roc_curve()` | `roc()` | `ROC_CURVE()` | ROC curve data |
| Comprehensive Evaluation | `classification_report()` | Custom functions | `CLASSIFICATION_EVALUATOR()` | Complete classification assessment |

### Clustering Metrics

| Metric | Python (scikit-learn) | R | Vertica SQL | Vertica Function |
|--------|----------------------|---|-------------|------------------|
| Silhouette Score | `silhouette_score()` | `silhouette()` | `SILHOUETTE_SCORE()` | Cluster quality measure |
| Inertia | `kmeans.inertia_` | `kmeans_object$tot.withinss` | `INERTIA()` | Within-cluster sum of squares |
| Comprehensive Evaluation | Custom functions | Custom functions | `CLUSTERING_EVALUATOR()` | Complete clustering assessment |

## Data Preparation Functions

### Missing Value Handling

| Strategy | Python (pandas/scikit) | R | Vertica SQL | Vertica Function |
|----------|------------------------|---|-------------|------------------|
| Mean imputation | `fillna(df.mean())` | `replace_na(mean())` | `IMPUTE(USING PARAMETERS strategy='mean')` | Mean replacement |
| Median imputation | `fillna(df.median())` | `replace_na(median())` | `IMPUTE(USING PARAMETERS strategy='median')` | Median replacement |
| Mode imputation | `fillna(df.mode())` | `replace_na(mode())` | `IMPUTE(USING PARAMETERS strategy='mode')` | Mode replacement |
| Forward fill | `fillna(method='ffill')` | `na.locf()` | `FILL(USING PARAMETERS method='forward')` | Forward fill |
| Backward fill | `fillna(method='bfill')` | `na.locf(fromLast=TRUE)` | `FILL(USING PARAMETERS method='backward')` | Backward fill |

### Outlier Detection

| Method | Python | R | Vertica SQL | Vertica Function |
|--------|--------|---|-------------|------------------|
| Z-Score | `scipy.stats.zscore()` | `scale()` | `DETECT_OUTLIERS(USING PARAMETERS method='zscore')` | Z-score based detection |
| IQR Method | Custom calculation | Custom calculation | `DETECT_OUTLIERS(USING PARAMETERS method='iqr')` | Interquartile range method |
| Isolation Forest | `IsolationForest()` | `isolationForest()` | `ISOLATION_FOREST()` | Advanced anomaly detection |

### Feature Engineering

| Operation | Python (pandas) | R | Vertica SQL | Notes |
|-----------|----------------|---|-------------|-------|
| Normalization | `(x - x.min()) / (x.max() - x.min())` | `scale(x, center=FALSE)` | `NORMALIZE()` | Min-max scaling |
| Standardization | `(x - x.mean()) / x.std()` | `scale(x)` | `NORMALIZE(USING PARAMETERS method='zscore')` | Z-score normalization |
| Log transformation | `np.log(x)` | `log(x)` | `LN()` or `LOG()` | Logarithmic transform |
| Polynomial features | `PolynomialFeatures()` | `poly()` | Manual calculation | Use arithmetic operators |
| Binning | `pd.cut()` | `cut()` | `WIDTH_BUCKET()` | Equal-width binning |

## Model Management

### Model Persistence

| Operation | Python (joblib/pickle) | R | Vertica SQL | Vertica Approach |
|-----------|-----------------------|---|-------------|------------------|
| Save model | `joblib.dump(model, 'file.pkl')` | `saveRDS(model, 'file.rds')` | Automatic | Models stored in `v_catalog.models` |
| Load model | `joblib.load('file.pkl')` | `readRDS('file.rds')` | Automatic | Models loaded by name |
| List models | File system | File system | `SELECT * FROM v_catalog.models` | Query system tables |
| Delete model | Delete file | Delete file | `DELETE_MODEL('model_name')` | Remove from catalog |

### Model Information

| Operation | Python | R | Vertica SQL | Vertica Function |
|-----------|--------|---|-------------|------------------|
| Model summary | `model.summary_` | `summary(model)` | `GET_MODEL_ATTRIBUTE('model', 'summary')` | Get model details |
| Feature importance | `model.feature_importances_` | `importance(model)` | `GET_MODEL_ATTRIBUTE('model', 'feature_importance')` | Feature importance |
| Model parameters | `model.get_params()` | `model$parameters` | `GET_MODEL_ATTRIBUTE('model', 'parameters')` | Model parameters |

## Cross-Validation and Hyperparameter Tuning

### Cross-Validation

| Method | Python (scikit-learn) | R | Vertica SQL | Vertica Approach |
|--------|----------------------|---|-------------|------------------|
| K-Fold CV | `cross_val_score()` | `cv.glmnet()` | `CROSS_VALIDATE()` | In-database cross-validation |
| Time Series CV | `TimeSeriesSplit()` | Custom implementation | `TIME_SERIES_CV()` | Time-aware validation |

### Hyperparameter Tuning

| Method | Python (scikit-learn) | R | Vertica SQL | Vertica Approach |
|--------|----------------------|---|-------------|------------------|
| Grid Search | `GridSearchCV()` | `tune()` | `GRID_SEARCH()` | Exhaustive parameter search |
| Random Search | `RandomizedSearchCV()` | Custom implementation | `RANDOM_SEARCH()` | Random parameter sampling |
| Bayesian Optimization | `BayesSearchCV()` | `mlrMBO()` | Manual implementation | Custom optimization logic |

## Integration Patterns

### Python Integration

```python
# Python with Vertica ML functions
import vertica_python

# Connect to Vertica
conn = vertica_python.connect(**connection_info)
cursor = conn.cursor()

# Train model using Vertica SQL
cursor.execute("""
    SELECT RF_CLASSIFIER(
        'my_model', 'training_data',
        'target', 'feature1, feature2, feature3'
    )
""")

# Make predictions
cursor.execute("""
    SELECT PREDICT_RF_CLASSIFIER(
        feature1, feature2, feature3
        USING PARAMETERS model_name='my_model'
    )
FROM new_data
""")
```

### R Integration

```r
# R with Vertica ML functions
library(RODBC)

# Connect to Vertica
conn <- odbcConnect("VerticaDSN")

# Use Vertica ML functions
sqlQuery(conn, "SELECT LINEAR_REG('model', 'data', 'target', 'features')")
```

## Migration Examples

### Example 1: scikit-learn to Vertica

**Python (scikit-learn):**
```python
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split

# Prepare data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Train model
model = RandomForestClassifier(n_estimators=100, max_depth=10)
model.fit(X_train, y_train)

# Make predictions
predictions = model.predict(X_test)
```

**Vertica SQL Equivalent:**
```sql
-- Train model
SELECT RF_CLASSIFIER(
    'customer_churn_model',
    'training_data',
    'churned',
    'feature1, feature2, feature3',
    'ntree' := 100,
    'max_depth' := 10
);

-- Make predictions
SELECT customer_id,
       PREDICT_RF_CLASSIFIER(
           feature1, feature2, feature3
           USING PARAMETERS model_name='customer_churn_model'
       ) AS prediction
FROM test_data;
```

### Example 2: R to Vertica

**R:**
```r
# Train linear regression model
model <- lm(target ~ feature1 + feature2 + feature3, data=training_data)

# Make predictions
predictions <- predict(model, new_data)

# Evaluate model
summary(model)
r_squared <- summary(model)$r.squared
```

**Vertica SQL Equivalent:**
```sql
-- Train linear regression model
SELECT LINEAR_REG(
    'revenue_model',
    'training_data',
    'target',
    'feature1, feature2, feature3'
);

-- Make predictions
SELECT id,
       PREDICT_LINEAR_REG(
           feature1, feature2, feature3
           USING PARAMETERS model_name='revenue_model'
       ) AS prediction
FROM new_data;

-- Get model summary
SELECT GET_MODEL_ATTRIBUTE('revenue_model', 'r_squared') AS r_squared;
```

## Best Practices for Migration

1. **Data Preparation**: Ensure data is properly formatted before training
2. **Feature Engineering**: Perform feature engineering in SQL for consistency
3. **Model Validation**: Use Vertica's built-in evaluation functions
4. **Performance**: Leverage Vertica's parallel processing capabilities
5. **Deployment**: Create views for real-time predictions

## Performance Considerations

- **In-database processing**: No data movement required
- **Parallel execution**: Leverages Vertica's MPP architecture
- **Columnar storage**: Efficient for feature-based operations
- **Compression**: Reduced I/O for large datasets
- **Projection design**: Optimize for ML workload patterns