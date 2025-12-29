# Spotify Popularity Analysis (Data 101 Capstone)

**Project:** Final Data 101 Capstone – Can Data Fool Us... or Make Us Famous?  
**Dataset:** [Spotify Top 50 Songs (2019)](https://www.kaggle.com/datasets/leonardopena/top50spotify2019)  

## Overview
This project explores the Spotify Top 50 songs of 2019 to investigate factors that influence **song popularity**. Using R, we perform **data cleaning, feature engineering, statistical analysis, predictive modeling, and association rule mining**.

## Key Steps
1. **Data Preparation & Feature Engineering**
   - Renamed columns for clarity
   - Created `is_long` (long vs short songs) and `high_pop` (high vs low popularity)
   - Computed `vibe_score = energy * valence`

2. **Exploratory Data Analysis (EDA)**
   - Visualized distributions (`hist`, `boxplot`)
   - Explored relationships between audio features and popularity

3. **Statistical Analysis**
   - Confidence intervals and central limit theorem
   - Hypothesis testing: z-tests, permutation tests
   - Independence testing: chi-square tests
   - Multiple hypothesis testing: Bonferroni and Benjamini-Hochberg adjustments
   - Bayesian updating of probabilities

4. **Prediction Modeling**
   - Train/test split (70/30)
   - Decision tree model predicting `high_pop` using `energy`, `danceability`, `valence`, and `bpm`
   - Evaluated training and testing accuracy
   - Confusion matrix and baseline comparison

5. **Association Rules & Lift**
   - Generated rules to find patterns between audio features and popularity
   - Identified strong rules with `lift > 1`

## Tools & Libraries
- R packages: `rpart`, `rpart.plot`, `arules`, `HypothesisTesting`

## Key Insights
- Song length and energy/valence combinations affect popularity trends
- Decision tree models can predict high vs low popularity better than chance
- Association rules reveal feature combinations that correlate with popularity

## How to Run
1. Clone the repository
2. Open `spotify_analysis.R` in RStudio
3. Ensure required packages are installed
4. Run the script to reproduce analysis, visualizations, and prediction results


