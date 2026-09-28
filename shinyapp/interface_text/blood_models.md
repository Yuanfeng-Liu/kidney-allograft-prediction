-   To find the best-performing predictive model, 5 different approaches commonly used in data science are tested

-   Each model was trained and tested multiple times on different group of the train set to ensure it could generalise well, rather than just perform well on 1 specific group

-   We paid special attention to how well each model could correctly identify rejection cases, without misclassifying too many stable ones

-   After comparing their consistency and reliability across all tests, **XGBoost** appears as the most suitable model for blood data

-   This was chosen since it offered the best balance between sensitivity *(catching rejections*) and overall prediction stability
