# Gakudo AI App Documentation

## Project Overview
A Flutter application that provides booking management, quiz functionality, payment integration, and user authentication.

## Architecture
The project follows a Clean Architecture pattern with BLoC (Business Logic Component) for state management:

- **Presentation Layer**: Screens and Widgets
- **Business Logic Layer**: BLoCs
- **Data Layer**: Repositories
- **Domain Layer**: Models and Entities

## Key Components

### Authentication
- Handles user login/signup
- Token-based authentication
- User profile management
- Repository: `AuthRepository`, `AuthRepositoryImpl`

### Booking System
- Session booking functionality
- Booking history management
- Cancellation and rescheduling
- Repository: `BookingRepository`, `BookingRepositoryImpl`

### Quiz System
- Quiz taking functionality
- Progress tracking
- Report generation
- Repository: `QuizRepository`, `QuizRepositoryImpl`

### Payment Integration
- Razorpay integration
- Payment status tracking
- Feature-based payments (chat, session, report)
- Bloc: `PaymentBloc`

## Repository Structure

### Auth Repository
- Login/Signup
- Profile management
- Token management
- Password reset

### Booking Repository
- Create bookings
- Fetch booking history
- Cancel bookings
- Reschedule bookings

### Quiz Repository
- Load quizzes
- Submit responses
- Check completion status
- Generate/download reports

## State Management

### BLoCs
- `BookingBloc`: Manages booking operations
- `QuizBloc`: Handles quiz interactions
- `PaymentBloc`: Controls payment flows
- `ChatBloc`: Manages chat functionality

## API Integration
- Base URL configuration
- Endpoint management via `ApiConstants`
- HTTP client implementation
- Error handling

## Features

### Booking Management
- Create new bookings
- View booking history
- Cancel/reschedule appointments
- Payment integration

### Quiz System
- Take quizzes
- Track progress
- Generate reports
- Download functionality

### Payment System
- Feature-based payments
- Razorpay integration
- Payment status tracking
- Order creation

### User Management
- Authentication
- Profile management
- Session handling
- Token management

## Dependencies
- `flutter_bloc`: State management
- `http`: API calls
- `shared_preferences`: Local storage
- `razorpay_flutter`: Payment integration
- `flutter_screenutil`: Responsive design

## Getting Started
1. Clone the repository
2. Install dependencies: `flutter pub get`
3. Configure API endpoints in `api_constants.dart`
4. Run the app: `flutter run`

## Best Practices
- Repository pattern for data layer
- BLoC pattern for state management
- Clean Architecture principles
- Proper error handling
- Code organization by feature
