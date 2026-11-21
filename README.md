# CareLoop No-Show Guard

An end-to-end project to understand and predict missed healthcare appointments.

This project uses Python, SQL, Machine Learning and Generative AI to analyse appointment data.

The main aim is to identify appointments that are more likely to be missed, understand the possible reasons and suggest actions clinics can take to reduce no-shows.

---

## Project Overview

Missed appointments can affect clinic operations, waste available appointment slots and make it difficult for other patients to get appointments.

In this project, we worked with appointment, clinic and patient follow-up data to understand no-show patterns and build a model that can identify appointments at risk of being missed.

We divided the project into four parts:

1. Data ingestion, cleaning and preparation using Python.
2. Database creation and analysis using SQL.
3. No-show prediction using Machine Learning.
4. Analysis of patient follow-up notes using Generative AI.

## Part 1: Data Ingestion, Cleaning and Preparation

We started by reading the data using Python's `csv.DictReader`. However, it stores values as strings by default, which makes calculations and data manipulation difficult. So, we moved to Pandas, which made it easier to clean, manipulate and analyse the data.

Next, we performed data cleaning by removing duplicate records and dropping rows with missing appointment dates or statuses. This reduced our dataset from **1,020 to 990 rows**. We then checked for invalid values, such as ages below 1 or above 100, using Boolean Masking.

For missing numerical values, we used median imputation because the median is less affected by extreme values and outliers. We also applied the IQR method to identify unusually high values in columns such as distance and consultation fees, and clipped values that exceeded the upper limits.

Once the cleaning was complete, we moved to feature engineering. We created a new feature called `lead_days`, which represents the number of days between booking an appointment and the actual appointment date. We also converted the appointment status into a numerical target variable, where 1 represented a no-show and 0 represented an attended appointment.

We then used NumPy to perform calculations such as finding average values, identifying appointments booked more than 14 days in advance and detecting unusual distance values using Z-scores.

After this, we enriched the clinic data using the Open-Meteo API to obtain weather information for the clinics. We handled API errors and added the weather information to our clinic dataset.

Finally, we sorted and exported the cleaned appointment data and enriched clinic data into CSV files. We also generated SQL INSERT statements for both datasets, preparing them to be loaded into MySQL for further analysis in Part 2.

## Part 2: SQL Database and Analysis

In Part 2, we started by creating a database called `noshowguard` in MySQL. We then created two tables, `appointments` and `clinics`, and inserted the cleaned data from Part 1 using the SQL file we had generated.

Once the data was loaded, we started analysing appointment no-show patterns using SQL queries.

First, we calculated the no-show percentage for each clinic using `INNER JOIN`, `GROUP BY` and `HAVING`. This helped us compare the performance of different clinics and identify those with higher no-show rates.

Next, we analysed whether the number of days between booking an appointment and the actual appointment date affected no-shows. We used `CASE WHEN` to divide appointments into different booking lead-time groups. From our analysis, we observed that appointments booked further in advance generally had higher no-show rates.

We then looked at the month-to-month trend in no-show percentages. Using a CTE (Common Table Expression) and the `LAG()` function, we compared each month's no-show rate with the previous month to understand how it changed over time.

After that, we used `RANK()` with `PARTITION BY` to rank clinics within their respective cities based on their no-show percentages. This helped us compare clinics operating in the same city.

Finally, we compared each clinic's no-show percentage with the overall no-show percentage across all clinics. This helped us identify which clinics were performing better or worse than the overall average.

Overall, Part 2 helped us understand how no-show rates differed across clinics, booking lead times and months. These findings also gave us a better understanding of the data before moving on to Machine Learning in Part 3.

## Part 3: Machine Learning and Model Evaluation

In Part 3, we moved on to building Machine Learning models to predict whether an appointment was likely to be missed.

First, we separated the input features (`X`) from the target variable (`y`). We then converted the `reminder_sent` column using binary encoding and applied one-hot encoding to `booking_channel` and `visit_type`. After preparing the data, we split it into training and testing sets.

Before building the models, we checked the baseline accuracy, which was approximately **75%**. This gave us a benchmark that our models needed to improve upon.

We started with Logistic Regression. Since the model works better when numerical features are on a similar scale, we used `StandardScaler` to scale the data. We made sure the scaler was fitted only on the training data to avoid data leakage. The model achieved an accuracy of **78.79%**, precision of **62.96%**, recall of **34.69%** and F1-score of **44.74%**. We also evaluated it using a confusion matrix and ROC-AUC curve.

Next, we tried a Decision Tree. We first trained a tree without restricting its depth. It achieved 100% training accuracy but performed less well on the test data, indicating overfitting. We then restricted the tree using `max_depth=3`, which gave a better balance, with **82.20% training accuracy** and **77.78% test accuracy**.

After that, we built a Random Forest Classifier, which achieved **74.75% accuracy**, **30.61% recall** and a **0.706 ROC-AUC score**.

We also used `GridSearchCV` to test different parameter combinations and tune the Random Forest model. We then compared the models using 5-fold cross-validation. Logistic Regression had the highest mean ROC-AUC score of **0.7737**, so we selected it for the final model.

Finally, we used out-of-fold predictions to select an optimal classification threshold instead of automatically using the default 0.50 threshold. We gave more importance to recall because missing a patient who is likely to skip an appointment (False Negative) can be more costly to the clinic than sending an unnecessary reminder to someone who eventually attends (False Positive).

Therefore, we selected a threshold of **0.35** to improve the model's ability to identify appointments at risk of being missed.

We then evaluated the final model on the test set, achieving a **ROC-AUC of 0.7889** and an **F1-score of 0.5714**. Precision and recall were also **57.14%** each. The model flagged **49 appointments** as high risk out of 198 test appointments.

Finally, we exported the predicted risk probabilities and flags into `test_risk_scores.csv`.

## Part 4: Generative AI and Analysis of Follow-up Notes

In Part 4, we used Generative AI to analyse patient follow-up notes and understand the possible reasons behind missed appointments.

We started by connecting to the Gemini API and creating a function to send follow-up notes to the model for analysis. Instead of receiving unstructured text, we wanted the model to return information in a fixed format.

For this, we used Pydantic to define a structured output with four fields: `root_cause`, `confidence`, `summary` and `recommended_action`. We also added validation rules to make sure the model returned values in the expected format and that the confidence score stayed between 0 and 1.

Next, we used the CRAFT prompting approach to make our instructions clearer and guide Gemini towards more relevant and consistent responses. We processed the follow-up notes and stored the structured results, along with the raw responses, for further analysis.

We also tested how the model handled invalid or incomplete inputs and checked the validation process. To understand the impact of better instructions, we compared the results from a simple prompt with those from our CRAFT prompt.

Finally, we combined the analysed follow-up notes with our appointment data to connect the reasons mentioned in the notes with appointment no-show patterns. This helped us move beyond simply predicting which appointments might be missed and understand some of the reasons behind those missed appointments.

The final analysed data was exported to `notes_analysed.csv`.

## Key Findings and Business Recommendations

During our analysis, we found that **218 out of 990 appointments were missed**, giving an overall no-show rate of approximately **22%**. This shows that missed appointments are an important issue for clinics.

We also observed that appointments booked further in advance generally had higher no-show rates. Around **296 appointments (29.9%) were booked more than 14 days in advance**. This suggests that patients who book well ahead may need additional reminders or confirmation.

Our clinic-level analysis helped us compare each clinic's no-show percentage with the overall rate of **22%**. This can help clinics identify where attendance needs more attention.

For Machine Learning, Logistic Regression was selected for the final model. We used a classification threshold of **0.35** because identifying patients who might miss appointments was more important than avoiding every unnecessary reminder. On the test set of **198 appointments**, the model flagged **49 appointments** as high risk. It achieved a test ROC-AUC of **0.7889**, with precision, recall and F1-score of **57.14%** each.

Based on these findings, we recommend the following actions:

1. **Focus on appointments booked well in advance:** Since no-show rates generally increased with booking lead time, clinics can send additional reminders or ask patients to confirm appointments booked more than 14 days ahead.

2. **Prioritise high-risk appointments:** Clinics can use the model's risk scores to identify patients who may need a reminder or confirmation call. This can help staff focus their time on appointments that need more attention.

3. **Monitor clinic performance:** Clinics with no-show rates higher than the overall rate of 22% should review their appointment and reminder processes.

4. **Make better use of vacant slots:** When a patient cancels or confirms that they cannot attend, clinics can contact patients on a waiting list and offer the available slot to someone else.

5. **Use follow-up notes to understand reasons:** The structured insights from Generative AI can help clinics understand common reasons mentioned by patients, such as forgetting appointments, transport difficulties, fees or work schedules. Clinics can use this information to plan suitable improvements.

The main aim is not just to predict missed appointments, but to help clinics take action early, reduce unused appointment slots and make better use of their time.

## Limitations

Although the project gave us useful insights, there are a few limitations to consider:

- **Limited dataset:** The analysis was based on 990 cleaned appointments from 8 clinics. A larger dataset covering more clinics and a longer period could provide more reliable insights.

- **Model predictions are not always correct:** The Logistic Regression model achieved a test F1-score of 57.14%. This means there is still room for improvement, and some appointments may be incorrectly classified.

- **Trade-off between false positives and false negatives:** We selected a threshold of 0.35 to give more importance to recall. This can help identify more potential no-shows, but it can also result in more patients being flagged even though they eventually attend.

- **Limited follow-up notes:** The Generative AI analysis was based on only 10 follow-up notes. A larger set of notes would help us understand patient reasons more reliably.

- **Generative AI responses may not always be accurate:** Even with structured output and Pydantic validation, the model may interpret a patient's note incorrectly. The results should be reviewed rather than treated as confirmed facts.

- **Weather data does not prove the reason for a no-show:** Weather information was added as extra context, but it does not establish that weather conditions caused a patient to miss an appointment.

Overall, this project provides a starting point for understanding and reducing appointment no-shows. The model and findings should be tested with more real-world data and monitored over time before being used in actual clinic operations.

## Tools and Technologies Used

- **Python:** Pandas, NumPy
- **Data visualisation and analysis:** Matplotlib, Seaborn
- **Database:** MySQL
- **Machine Learning:** Scikit-learn
- **Generative AI:** Gemini API, Pydantic
- **Weather data:** Open-Meteo API
- **Platform:** Google Colab, MySQL Workbench and GitHub


**Note:** The Gemini API key is not included in this repository.

