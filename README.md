# MoniFlora Mobile
This app is part of my thesis project, and its primary objective is to facilitate the development of a condition monitoring app that leverages machine learning models and data analysis techniques to predict plant health assessment.

## Key Features:
**1. Real-Time Condition Monitoring:** Monitor the health and conditions of your plants in real-time.
**2. Machine Learning Integration:** Utilize advanced machine learning models to assess plant health.
**3. Data Analysis:** Analyze data to predict potential issues and optimize plant care.

## Additional Resources:
For more information about the dataset and machine learning model examples used in this app, check out my [Cherry Tomato Parameter dataset on Kaggle](https://www.kaggle.com/datasets/andresaftari/moniflora-backup-rtdb/data).

For more information about the MoniFlora-CLI used to gather the sensor data and then upload them into Firebase RTDB, check out my [MoniFlora-CLI Repository](https://github.com/andresaftari/MoniFlora-Skripsi-CLI)

For more information about the Random Forest model I used to predict the plant condition classification, take a look on my [Cherry Tomato Condition Prediction model on Kaggle](https://www.kaggle.com/code/andresaftari/cherry-tomato-condition-prediction)

To test the Model API directly, try this:
1. Use ApiDog, Postman (or any other API Testing Platform)
2. Hit `https://andresaftari.pythonanywhere.com/predict` with POST
3. Use RAW JSON body **(Note: Make sure the body type is JSON, otherwise it won't work)**
4. Write the body like this example:
`{ "temperature": 24.0, "light": 5384, "conductivity": 1200, "moisture": 42 }`
5. SEND IT!

Feel free to try all the available additional resources here, thank you for trying out Moniflora!
I'm open for any feedback :)


