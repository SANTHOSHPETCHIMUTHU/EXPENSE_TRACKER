# Expense Tracker

A modern and feature-rich expense tracking application built with Flutter that helps you manage your personal and group expenses effectively.

## Features

### Individual Expense Management
- Track personal expenses with detailed categorization
- Add custom expense categories
- View expenses in bar chart or pie chart format
- Filter expenses by time periods (Today, This Week, This Month, All)
- Export expenses to CSV format

### Group Expense Management
- Split expenses among multiple people
- Support for equal and percentage-based splitting
- Track shared expenses with detailed breakdown
- Manage group members and their contributions

### Budget Planning
- Set monthly budgets
- Create budget categories with custom limits
- Track spending against budget limits
- Visual representation of budget utilization

### Reports and Analytics
- Comprehensive expense reports
- Date range selection for analysis
- Visual charts for expense distribution
- Combined view of individual and group expenses
- Export functionality for reports

### Additional Features
- Firebase Authentication for secure login
- Google Sign-in integration
- Dark mode support
- Material Design 3 UI
- Responsive layout
- Data persistence using SharedPreferences
- Beautiful charts using fl_chart
- Currency formatting with Indian Rupee (₹) support

## Technical Stack

- **Framework**: Flutter
- **State Management**: Provider
- **Authentication**: Firebase Auth
- **Data Storage**: SharedPreferences
- **Charts**: fl_chart
- **UI Components**: Material Design 3
- **Fonts**: Google Fonts (Poppins)
- **Date Formatting**: intl
- **Sharing**: share_plus

## Getting Started

### Prerequisites
- Flutter SDK (^3.7.0)
- Dart SDK
- Firebase project setup

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/expense_tracker.git
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Create a new Firebase project
   - Add your Firebase configuration to `lib/firebase_options.dart`
   - Enable Google Sign-in in Firebase Console

4. Run the app:
```bash
flutter run
```

## Usage

1. **Sign In**
   - Use email/password or Google Sign-in to access the app

2. **Individual Expenses**
   - Add new expenses with description, amount, and category
   - View expense distribution in charts
   - Filter expenses by time period
   - Export expenses to CSV

3. **Group Expenses**
   - Create group expenses with multiple participants
   - Choose between equal or percentage-based splitting
   - Track individual contributions
   - View group expense history

4. **Budget Planning**
   - Set monthly budget
   - Create budget categories
   - Monitor spending against budget
   - Get alerts for budget limits

5. **Reports**
   - Select date range for analysis
   - View expense trends
   - Generate detailed reports
   - Export data for external analysis

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for authentication and backend services
- All the package authors whose work made this app possible
