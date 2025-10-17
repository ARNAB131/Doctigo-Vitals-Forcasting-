import os
from datetime import datetime
import pandas as pd


class DataManager:
    """Handles data loading, saving, and vital history with safe CSV init."""

    def __init__(self, config):
        self.data_path = getattr(config, "data_path", "data/vitals.csv")
        self.feature_columns = [
            "heart_rate", "bp_systolic", "bp_diastolic", "oxygen_saturation", "temperature"
        ]
        self.base_cols = ["patient_id", "timestamp", "sensor", "value"] + self.feature_columns

        # Ensure directory exists
        os.makedirs(os.path.dirname(self.data_path), exist_ok=True)

        # Initialize or repair CSV schema
        if not os.path.exists(self.data_path) or os.path.getsize(self.data_path) == 0:
            pd.DataFrame(columns=self.base_cols).to_csv(self.data_path, index=False)
        else:
            try:
                df = pd.read_csv(self.data_path)
            except pd.errors.EmptyDataError:
                # File exists but is empty/corrupt
                pd.DataFrame(columns=self.base_cols).to_csv(self.data_path, index=False)
            else:
                # Ensure required columns exist
                mutated = False
                for col in self.base_cols:
                    if col not in df.columns:
                        df[col] = None
                        mutated = True
                # Drop unknown columns if you want strict schema (optional)
                # df = df[self.base_cols]
                if mutated:
                    df.to_csv(self.data_path, index=False)

    def load_data(self) -> pd.DataFrame:
        """Load CSV safely with required columns, even if file is empty or corrupt."""
        try:
            df = pd.read_csv(self.data_path)
            # Guarantee schema
            for col in self.base_cols:
                if col not in df.columns:
                    df[col] = None
            # Keep only known columns (optional but helps cleanliness)
            df = df[[c for c in self.base_cols if c in df.columns]]
            return df
        except (FileNotFoundError, pd.errors.EmptyDataError, ValueError):
            return pd.DataFrame(columns=self.base_cols)

    def save_data(self, df: pd.DataFrame) -> None:
        """Save DataFrame to CSV with guaranteed schema."""
        for col in self.base_cols:
            if col not in df.columns:
                df[col] = None
        df = df[self.base_cols]
        df.to_csv(self.data_path, index=False)

    def store_vital_sign(self, vital) -> None:
        """Store vitals in wide + long format (value column for graphing)."""
        # Support object or dict inputs
        pid = getattr(vital, "patient_id", None) or vital.get("patient_id")
        ts = getattr(vital, "timestamp", None) or vital.get("timestamp", datetime.now())
        sensor_type = getattr(vital, "sensor_type", None) or vital.get("sensor_type")
        value = getattr(vital, "value", None) or vital.get("value")

        # Normalize timestamp to string for CSV
        if not isinstance(ts, str):
            try:
                ts = pd.to_datetime(ts).strftime("%Y-%m-%d %H:%M:%S")
            except Exception:
                ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        df = self.load_data()

        mapping = {
            "ECG": "heart_rate",
            "BP_SYS": "bp_systolic",
            "BP_DIA": "bp_diastolic",
            "SpO2": "oxygen_saturation",
            "Temp": "temperature",
        }
        feature_col = mapping.get(sensor_type)

        new_row = {col: None for col in self.feature_columns}
        new_row.update({
            "patient_id": pid,
            "timestamp": ts,
            "sensor": sensor_type,
            "value": value,
        })
        if feature_col:
            new_row[feature_col] = value

        df = pd.concat([df, pd.DataFrame([new_row])], ignore_index=True)
        self.save_data(df)

    def get_patient_vitals_history(self, patient_id, sensor_type=None, limit=30):
        """Return the last N vitals for a patient. Optionally filter by sensor."""
        df = self.load_data()
        if df.empty:
            return []
        patient_data = df[df["patient_id"] == patient_id]
        if sensor_type:
            patient_data = patient_data[patient_data["sensor"] == sensor_type]
        return patient_data.tail(limit).to_dict("records")

    def store_prediction(self, prediction):
        # Implement if you persist predictions
        pass
