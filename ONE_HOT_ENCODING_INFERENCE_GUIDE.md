# Handling One-Hot Encoding & Missing Columns in ML Inference

> **Project:** British Airways Flight Booking Prediction  
> **Purpose:** Document the approach for handling categorical encoding and column alignment between training and inference

---

## The Problem

When training a model with one-hot encoded categorical features, you create multiple columns from a single categorical column:

**Example - Training Data:**
```
trip_type values: ["RoundTrip", "OneWay", "CircleTrip"]
→ Creates: trip_type_RoundTrip, trip_type_OneWay, trip_type_CircleTrip
```

**Problem during Inference:**
- User inputs only ONE value: `"RoundTrip"`
- The one-hot encoder needs to create ALL columns (with 1 for match, 0 for others)
- Missing columns or incorrect column order will cause prediction errors

---

## The Solution

### 1. Save the Fitted Encoder from Training

**During Training:**
```python
from sklearn.preprocessing import OneHotEncoder
import joblib

# Fit encoder on training data
oh_encoder = OneHotEncoder(sparse_output=False, drop='first')
oh_encoder.fit(df[['trip_type']])

# Save the fitted encoder
joblib.dump({'onehot_trip_type': oh_encoder}, 'encoders.joblib')
```

**Key Point:** The encoder "remembers" all categories it saw during training via `oh_encoder.categories_`

---

### 2. Load and Use the Encoder During Inference

```python
# Load saved encoder
encoders = joblib.load('encoders.joblib')
oh_encoder = encoders['onehot_trip_type']

# Transform single inference value
oh_result = oh_encoder.transform(df[['trip_type']])
cats = oh_encoder.categories_[0]

# Create column names matching training
oh_col_names = [f'{col}_{cat}' for cat in cats[1:]]  # skip first if drop='first'
oh_df = pd.DataFrame(oh_result, columns=oh_col_names, index=df.index)

# Replace original column with encoded columns
df = df.drop(columns=[col])
df = pd.concat([df, oh_df], axis=1)
```

---

### 3. Ensure Column Alignment with Expected Columns

**Critical Step:** Define exactly which columns the model expects:

```python
expected_columns = [
    'booking_origin', 'route', 'flight_duration', 'length_of_stay',
    'sales_channel', 'purchase_lead', 'wants_extra_baggage', 
    'wants_preferred_seat', 'wants_in_flight_meals', 
    'num_passengers', 'trip_type_OneWay', 'trip_type_RoundTrip'
]

# Add missing columns with 0 (for categories not present in this inference sample)
for col in expected_columns:
    if col not in df.columns:
        df[col] = 0

# Ensure exact column order
 df = df[expected_columns]
```

---

## Complete Inference Preprocessing Pipeline

```python
def preprocess_input(data, encoders, scalers):
    df = data.copy()
    
    # Step 1: One-hot encode categorical columns
    for col in ['trip_type', 'flight_day']:
        if col in df.columns:
            encoder_key = f'onehot_{col}'
            if encoder_key in encoders:
                oh_encoder = encoders[encoder_key]
                oh_result = oh_encoder.transform(df[[col]])
                cats = oh_encoder.categories_[0]
                
                # Create all columns the encoder knows about
                oh_col_names = [f'{col}_{cat}' for cat in cats[1:]]
                oh_df = pd.DataFrame(oh_result, columns=oh_col_names, index=df.index)
                
                df = df.drop(columns=[col])
                df = pd.concat([df, oh_df], axis=1)
    
    # Step 2: Ensure all expected columns exist
    expected_columns = [
        'booking_origin', 'route', 'flight_duration', 'length_of_stay',
        'sales_channel', 'purchase_lead', 'wants_extra_baggage', 
        'wants_preferred_seat', 'wants_in_flight_meals', 
        'num_passengers', 'trip_type_OneWay', 'trip_type_RoundTrip'
    ]
    
    for col in expected_columns:
        if col not in df.columns:
            df[col] = 0
    
    # Step 3: Reorder columns to match training
    df = df[expected_columns]
    
    return df
```

---

## Example Flow

### Training Phase:
```
Input: trip_type = ["RoundTrip", "OneWay", "CircleTrip", "RoundTrip"]
↓
One-Hot Encoding:
  trip_type_OneWay:    [0, 1, 0, 0]
  trip_type_RoundTrip: [1, 0, 0, 1]
  trip_type_CircleTrip:[0, 0, 1, 0]
↓
Model learns on all 3 columns
```

### Inference Phase:
```
User Input: trip_type = "RoundTrip"
↓
Load saved encoder
↓
Transform:
  trip_type_OneWay:    [0]
  trip_type_RoundTrip: [1] 
  trip_type_CircleTrip:[0] ← created even though not in input!
↓
Select only columns model expects
  trip_type_OneWay:    [0]
  trip_type_RoundTrip: [1]
  (CircleTrip excluded if not in expected_columns)
↓
Model prediction ✓
```

---

## Key Takeaways

1. **Always save fitted encoders** from training, don't recreate them
2. **Use `encoder.categories_`** to get all possible values the encoder knows
3. **Create all columns** the encoder produces, even if only one input value
4. **Define `expected_columns`** list that matches your model's training features
5. **Fill missing columns with 0** to handle categories not present in inference data
6. **Reorder columns** to exactly match training order before prediction

---

## Common Pitfalls to Avoid

❌ **Don't recreate the encoder during inference** - it won't know all categories  
❌ **Don't assume input has all categories** - single values are normal in inference  
❌ **Don't forget to align columns** - order matters for most ML models  
❌ **Don't skip missing column handling** - will cause shape mismatch errors  

✅ **Do save encoders with joblib/pickle** after fitting on training data  
✅ **Do use the saved encoder's `categories_` attribute** to get all column names  
✅ **Do explicitly define expected columns** and ensure they all exist  
✅ **Do test inference** with single samples to verify pipeline works  

---

## Related Files in This Project

- `app.py` - Lines 75-122 contain the one-hot encoding and column alignment logic
- `models/encoders.joblib` - Saved encoders from training
- `models/scalers.joblib` - Saved scalers for numerical features
- `models/random_forest_model.joblib` - The trained model

---

*Last Updated: April 2025*
