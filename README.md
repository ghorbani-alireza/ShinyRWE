# 📊 Cohort Description Shiny App

This repository contains a **Shiny app** designed to provide a comprehensive description and visualization of a cohort of patients based on their baseline characteristics. The app allows users to explore the data, generate summary statistics, and visualize key demographic and clinical variables. Additionally, users can download the summary statistics for further analysis.

---

## 🚀 App Features

- **📋 Cohort Summary**: A detailed summary table displaying key statistics for each variable in the dataset, including mean, median, min, max, and quartiles for continuous variables, and frequency and percentage for categorical variables.
- **👥 Demographics & Lifestyle**: Visualizations of demographic and lifestyle variables, including age distribution, race, sex, and smoking status.
- **🏥 Clinical Variables**: Visualizations of clinical variables, including triglycerides, diabetic status, Anti-VEGF medications, visual acuity, wAMD status, and time in cohort.
- **🔍 Filtering Options**: Users can filter the data based on various criteria, such as geographical atrophy status, sex, age range, race, smoking status, diabetic status, wAMD status, and Anti-VEGF medications status.
- **📥 Download Summary**: Users can download the summary statistics as a CSV file for further analysis.

---

## 📂 Dataset

The dataset used in this Shiny app is **simulated data** created for the purpose of demonstrating the functionality of the dashboard. It does not represent real patient data. The dataset includes the following variables:

| Variable                     | Description                                                                 |
|------------------------------|-----------------------------------------------------------------------------|
| **Age**                      | Age of the patient.                                                         |
| **Race**                     | Race of the patient (Race1, Race2, Race3, Race4).                           |
| **Geographical_Atrophy_Status** | Geographical atrophy status (0 or 1).                                       |
| **wAMD**                     | wAMD status (0 or 1).                                                       |
| **Visual_Acuity**            | Visual acuity of the patient.                                               |
| **Smoking_Status**           | Smoking status (0 or 1).                                                    |
| **Triglycerides**            | Triglycerides level.                                                        |
| **Diabetic_Status**          | Diabetic status (0 or 1).                                                   |
| **Time_in_Cohort**           | Time spent in the cohort.                                                   |
| **AntiVEGF_Medications**     | Anti-VEGF medications status (0 or 1).                                      |
| **Sex**                      | Sex of the patient (Male or Female).                                        |

---

## 🛠️ How to Use the App

1. **🌐 Access the App**: The app is hosted on ShinyApps.io and can be accessed [here](https://ghorbani-alireza.shinyapps.io/bi_cohort_description/).

2. **🔍 Filter Data**: Use the sidebar filters to select the subset of data you are interested in. You can filter by:
   - Geographical atrophy status
   - Sex
   - Age range
   - Race
   - Smoking status
   - Diabetic status
   - wAMD status
   - Anti-VEGF medications status

3. **📋 View Summary Table**: The "Cohort Summary" tab displays a summary table of the filtered data. You can scroll through the table to view the statistics for each variable.

4. **📊 Visualize Data**: The "Demographics & Lifestyle" and "Clinical Variables" tabs provide visualizations of the filtered data. These include:
   - Density plots
   - Bar charts
   - Pie charts

5. **📥 Download Summary**: Click the "Download Summary" button to download the summary statistics as a CSV file.

---

## 🗂️ Repository Structure
```
📁 your-repo-name/
├── 📄 app.R # Main Shiny app script
├── 📄 data.csv # Simulated dataset
└── 📄 README.md # This file
```

---

## 💻 Running the App Locally

To run the Shiny app locally on your machine, follow these steps:

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/your-repo-name.git
   cd your-repo-name

2. **Install Required Packages**:
   ```R
    install.packages(c("shiny", "dplyr", "DT", "ggplot2", "gridExtra"))

3. **Run the App**:
    ```R
    shiny::runApp("app.R")

## 🤝 Contributing

Contributions are welcome! If you have any suggestions or find any issues, please open an issue or submit a pull request.

## 📜 License

The code in this repository is licensed under the MIT License. However, the simulated dataset (data.csv) is provided for demonstration purposes only and is not subject to the same license. The dataset is freely available for use in exploring the functionality of the dashboard but should not be used for any other purpose without modification.

## 📧 Contact
For any questions or feedback, please contact [me](mailto:ghorbanialireza@outlook.com).

Thank you for using the Cohort Description Shiny App! I hope it provides valuable insights into the functionality of the dashboard. Note that the data is simulated and intended for demonstration purposes only. 😊
