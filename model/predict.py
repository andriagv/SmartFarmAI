#!/usr/bin/env python3
"""
Smart Farm AI - Model Prediction Script
========================================
This script loads the trained XGBoost model and makes predictions on the test dataset.
"""

import pandas as pd
import numpy as np
import joblib
from sklearn.metrics import mean_squared_error, mean_absolute_error
import os
import argparse

def load_model_and_data():
    """Load the trained model and test data."""
    try:
        # Load the trained XGBoost model
        model = joblib.load('xgb_regressor_model.joblib')
        print("✅ Model loaded successfully!")
        
        # Load test data
        X_test = pd.read_csv('X_test.csv')
        y_test = pd.read_csv('y_test.csv')
        
        print(f"✅ Test data loaded successfully!")
        print(f"   - X_test shape: {X_test.shape}")
        print(f"   - y_test shape: {y_test.shape}")
        
        return model, X_test, y_test
        
    except FileNotFoundError as e:
        print(f"❌ Error: Could not find file - {e}")
        return None, None, None
    except Exception as e:
        print(f"❌ Error loading model or data: {e}")
        return None, None, None

def make_predictions(model, X_test):
    """Make predictions using the loaded model."""
    try:
        print("\n🔮 Making predictions...")
        predictions = model.predict(X_test)
        print(f"✅ Predictions completed! Generated {len(predictions)} predictions.")
        return predictions
    except Exception as e:
        print(f"❌ Error making predictions: {e}")
        return None

def evaluate_predictions(y_true, y_pred):
    """Evaluate the predictions against true values."""
    try:
        # Calculate metrics
        mse = mean_squared_error(y_true, y_pred)
        rmse = np.sqrt(mse)
        mae = mean_absolute_error(y_true, y_pred)
        
        print("\n📊 Model Performance Metrics:")
        print("=" * 40)
        print(f"Mean Squared Error (MSE):     {mse:.2f}")
        print(f"Root Mean Squared Error (RMSE): {rmse:.2f}")
        print(f"Mean Absolute Error (MAE):    {mae:.2f}")
        print("=" * 40)
        
        return {"MSE": mse, "RMSE": rmse, "MAE": mae}
        
    except Exception as e:
        print(f"❌ Error evaluating predictions: {e}")
        return None

def show_top_predictions(predictions, X_test, y_test, top_n=10):
    """Display the top N predictions with details."""
    try:
        results_df = pd.DataFrame({
            'actual_yield': y_test.iloc[:, 0].values,
            'predicted_yield': predictions,
            'difference': y_test.iloc[:, 0].values - predictions,
            'percentage_error': ((y_test.iloc[:, 0].values - predictions) / y_test.iloc[:, 0].values) * 100
        })
        
        # Add key features for context
        key_features = ['soil_moisture_%', 'soil_pH', 'temperature_C', 'rainfall_mm', 'humidity_%']
        for feature in key_features:
            if feature in X_test.columns:
                results_df[feature] = X_test[feature].values
        
        # Sort by actual yield (highest first) for "top" predictions
        top_results = results_df.nlargest(top_n, 'actual_yield')
        
        print(f"\n🏆 Top {top_n} Highest Yield Predictions:")
        print("=" * 120)
        print(f"{'#':<3} {'Actual':<8} {'Predicted':<10} {'Error':<8} {'Error%':<8} {'Soil_M%':<8} {'pH':<6} {'Temp°C':<7} {'Rain_mm':<9} {'Humid%':<8}")
        print("-" * 120)
        
        for idx, (_, row) in enumerate(top_results.iterrows(), 1):
            print(f"{idx:<3} {row['actual_yield']:<8.1f} {row['predicted_yield']:<10.1f} "
                  f"{abs(row['difference']):<8.1f} {abs(row['percentage_error']):<8.1f} "
                  f"{row['soil_moisture_%']:<8.1f} {row['soil_pH']:<6.2f} {row['temperature_C']:<7.1f} "
                  f"{row['rainfall_mm']:<9.1f} {row['humidity_%']:<8.1f}")
        
        print("=" * 120)
        return results_df
        
    except Exception as e:
        print(f"❌ Error showing top predictions: {e}")
        return None

def save_predictions(predictions, X_test, y_test, filename="predictions_results.csv"):
    """Save predictions to a CSV file with comparison to actual values."""
    try:
        results_df = pd.DataFrame({
            'actual_yield': y_test.iloc[:, 0].values,  # First column is yield
            'predicted_yield': predictions,
            'difference': y_test.iloc[:, 0].values - predictions,
            'percentage_error': ((y_test.iloc[:, 0].values - predictions) / y_test.iloc[:, 0].values) * 100
        })
        
        # Add some key features for context (first few columns)
        key_features = ['soil_moisture_%', 'soil_pH', 'temperature_C', 'rainfall_mm', 'humidity_%']
        for feature in key_features:
            if feature in X_test.columns:
                results_df[feature] = X_test[feature].values
        
        results_df.to_csv(filename, index=False)
        print(f"✅ Predictions saved to {filename}")
        
        return results_df
        
    except Exception as e:
        print(f"❌ Error saving predictions: {e}")
        return None

def main():
    """Main function to run the prediction pipeline."""
    # Set up argument parser
    parser = argparse.ArgumentParser(description='Smart Farm AI - Crop Yield Prediction')
    parser.add_argument('--show-data', action='store_true', 
                       help='Save detailed results to CSV file')
    args = parser.parse_args()
    
    print("🌾 Smart Farm AI - Crop Yield Prediction")
    print("=" * 50)
    
    # Change to the script's directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)
    print(f"📁 Working directory: {os.getcwd()}")
    
    # Load model and data
    model, X_test, y_test = load_model_and_data()
    if model is None:
        return
    
    # Make predictions
    predictions = make_predictions(model, X_test)
    if predictions is None:
        return
    
    # Evaluate predictions
    metrics = evaluate_predictions(y_test.iloc[:, 0], predictions)
    
    # Show top 10 predictions
    results_df = show_top_predictions(predictions, X_test, y_test, top_n=10)
    
    # Show summary statistics
    if results_df is not None:
        print(f"\n📈 Prediction Summary:")
        print(f"   - Average Actual Yield:    {results_df['actual_yield'].mean():.2f} kg/hectare")
        print(f"   - Average Predicted Yield: {results_df['predicted_yield'].mean():.2f} kg/hectare")
        print(f"   - Average Absolute Error:  {abs(results_df['difference']).mean():.2f} kg/hectare")
        print(f"   - Average Percentage Error: {abs(results_df['percentage_error']).mean():.2f}%")
    
    # Save results to CSV only if --show-data flag is provided
    if args.show_data:
        save_predictions(predictions, X_test, y_test)
        print(f"\n💾 Detailed results saved due to --show-data flag")
    else:
        print(f"\n💡 Use --show-data flag to save detailed results to CSV")
    
    print("\n🎉 Prediction pipeline completed successfully!")

if __name__ == "__main__":
    main() 