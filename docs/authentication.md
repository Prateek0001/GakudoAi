# Authentication Modules Documentation

## 1. Login Module

### Overview
The login module handles user authentication using username/password credentials.

### Components
- **LoginScreen**: UI component for login
- **LoginBloc**: Manages login state and business logic
- **AuthRepository**: Handles API communication

### Flow
1. User enters credentials
2. Validation
3. API call to `/api/v1/token`
4. Token storage in SharedPreferences
5. Navigation to Dashboard

### State Management 