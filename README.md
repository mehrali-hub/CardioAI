# 🫀 CardioAI — Heart Disease Risk Prediction

**An end-to-end ML platform that predicts cardiovascular risk and explains its reasoning.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.10%2B-blue.svg)](https://www.python.org/)
[![scikit-learn](https://img.shields.io/badge/scikit--learn-pipeline-orange.svg)](https://scikit-learn.org/)
[![XGBoost](https://img.shields.io/badge/XGBoost-trained-green.svg)](https://xgboost.readthedocs.io/)
[![Status](https://img.shields.io/badge/status-in--progress-yellow.svg)]()

---

## What this is

CardioAI predicts heart disease risk from 13 clinical features (age, chest pain type, resting blood pressure, cholesterol, ECG results, etc.) and is built to explain *why* it made that prediction — not just spit out a number. It's structured as a portfolio-grade healthcare AI project: real cross-validated model comparison, an explainability layer (SHAP), and a Flask backend designed to serve predictions through a web UI.

This repo currently covers **EDA → Preprocessing → Model Training** (Milestones 1–3 of the full build). The Flask backend (`app.py`) is scaffolded and is the next milestone.

## A genuinely interesting finding in this dataset

The correlation analysis in `01_EDA.ipynb` turns up something worth flagging: almost none of the individual features correlate strongly with `target` on their own (the strongest, `slope`, sits around r ≈ 0.32; most others are near zero). A naive read of that would suggest the data is weak. It isn't — it means the signal lives in **interactions between features**, not single-variable trends. That's exactly what the model comparison in `03_Model_Training.ipynb` confirms: Random Forest (CV ROC-AUC ≈ 0.885) and Logistic Regression (CV ROC-AUC ≈ 0.864) both clearly outperform what flat correlations alone would predict, because they pick up combinations like *chest-pain-type + exercise-induced-angina* or *age + max-heart-rate* that a single correlation coefficient can't see.

## What's inside

```
cardioai_project/
├── data/
│   ├── CardioAI_Merged_Heart_Dataset.csv   # raw dataset (599 rows, merged UCI sources)
│   └── processed/                          # train/test splits saved by 02_Preprocessing
├── notebooks/
│   ├── 01_EDA.ipynb                        # exploration, data quality, correlation analysis
│   ├── 02_Preprocessing.ipynb              # encoding, scaling, stratified split
│   └── 03_Model_Training.ipynb             # 4-model comparison, tuning, SHAP, persistence
├── models/
│   ├── cardioai_model.pkl                  # final tuned model (joblib)
│   ├── scaler.pkl                          # fitted StandardScaler
│   ├── feature_columns.pkl                 # exact feature order for inference
│   └── model_metadata.pkl                  # winning model name, params, test metrics
├── images/                                 # exported EDA & evaluation plots
├── app.py                                  # Flask backend (scaffolded — Milestone 4)
├── requirements.txt
├── LICENSE
└── README.md
```

## Pipeline

| Stage | Notebook | What happens |
|---|---|---|
| **EDA** | `01_EDA.ipynb` | Structure, missingness/duplicate audit, class balance, distribution plots, categorical disease-rate breakdowns, full correlation analysis |
| **Preprocessing** | `02_Preprocessing.ipynb` | One-hot encode nominal categoricals (`cp`, `restecg`, `slope`, `thal`); `StandardScaler` fit on train only; stratified 80/20 split; artifacts persisted for reuse |
| **Model Training** | `03_Model_Training.ipynb` | Logistic Regression, Decision Tree, Random Forest, XGBoost — 5-fold stratified CV scored on Accuracy/Precision/Recall/F1/ROC-AUC; `GridSearchCV` tuning on the leading candidate; SHAP explainability; final hold-out test evaluation; `joblib` persistence |

## Results

### Cross-validated comparison (training set, 5-fold)

| Model | Mean ROC-AUC |
|---|---|
| **Random Forest** | **0.877** |
| Logistic Regression | 0.864 |
| XGBoost | 0.852 |
| Decision Tree | 0.708 |

### Final model: Random Forest (tuned)

After `GridSearchCV` tuning (`max_depth=5, min_samples_split=2, n_estimators=100`), evaluated once on the held-out test set:

| Metric | Score |
|---|---|
| Accuracy | 0.767 |
| Precision | 0.767 |
| Recall | 0.767 |
| F1 | 0.767 |
| ROC-AUC | 0.860 |

## Running it yourself

```bash
# 1. Set up environment
pip install -r requirements.txt

# 2. Run the notebooks in order
jupyter notebook notebooks/01_EDA.ipynb
jupyter notebook notebooks/02_Preprocessing.ipynb
jupyter notebook notebooks/03_Model_Training.ipynb
```

## Using the saved model

```python
import joblib
import pandas as pd

model = joblib.load("models/cardioai_model.pkl")
scaler = joblib.load("models/scaler.pkl")
feature_columns = joblib.load("models/feature_columns.pkl")

# new_patient must be one-hot encoded the same way as in 02_Preprocessing.ipynb,
# then reindexed to feature_columns and scaled with the saved scaler before predicting
prediction = model.predict(new_patient_processed)
probability = model.predict_proba(new_patient_processed)[:, 1]
```

## Methodology notes

- **No leakage**: the `StandardScaler` is fit exclusively on the training split in `02_Preprocessing.ipynb`; the test set is transformed using train-fitted parameters only, and is not referenced again until final evaluation in `03_Model_Training.ipynb`.
- **Model selection on CV, not test**: all four candidates are ranked by 5-fold cross-validated ROC-AUC on training data before the winner ever touches the test set.
- **Stratified split**: preserves the near-50/50 class balance in both train and test, since the dataset has no severe imbalance to begin with.
- **Explainability**: SHAP values are computed for the final model to support the AI assistant's "explain this result" feature in the planned frontend (FR-004).

## Disclaimer

This is an educational and portfolio project, **not a certified medical device**. Predictions should never be used as a substitute for professional medical diagnosis or treatment.

## Roadmap

- [x] Milestone 1 — Documentation
- [x] Milestone 2 — EDA
- [x] Milestone 3 — Model Training
- [ ] Milestone 4 — Backend (Flask API: `/predict`, `/chat`, `/history`, `/report`)
- [ ] Milestone 5 — Frontend
- [ ] Milestone 6 — AI Integration (Gemini-powered explanation assistant)
- [ ] Milestone 7 — Deployment (Docker + Render)
- [ ] Milestone 8 — Portfolio Optimization

## Author

**Mehr** — BS Computer Science (FAST NUCES ), Machine Learning Engieer & Data Science in progress.

## License

Released under the [MIT License](LICENSE) — free to use, modify, and distribute.
