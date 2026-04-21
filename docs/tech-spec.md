TECHNICAL SPECIFICATION
Project: agartu – Social Network

1. General Information
Project Name: AgartU
Application Type: Mobile Application (Flutter)
Purpose: A mini social network app that allows users to create posts, interact with content, and view a dynamic feed.
2. Project Objective
The goal of this project is to develop a mobile application that allows users to:
●	register and log in
●	create and view posts
●	interact with posts (likes)
●	fetch external data via API
●	store user preferences locally
3. 👤 User Features
The user can:
●	register using email and password
●	log in to the system
●	log out
●	create a post
●	view a feed of posts
●	like posts
●	edit profile information
●	change application language
●	switch theme (light/dark mode)

4. Functional Requirements
4.1 Authentication (Firebase Authentication)
●	user registration (email + password)
●	user login
●	user logout
●	authentication state check on app startup
4.2 Feed Screen
●	display all posts from users
●	posts are sorted by creation date
●	each post includes:
○	post text
○	username
○	number of likes
4.3 Create Post
●	text input field (TextFormField)
●	“Post” button
●	saving data to Firestore
4.4 Database (Cloud Firestore)
Posts must be stored with the following fields:
●	postId
●	userId
●	username
●	content
●	createdAt
●	likesCount
4.5 API Integration (Dio / Retrofit)
●	fetch data from a public API
●	display data in the “Explore” section
●	examples: quotes, memes, or news
●	
4.6 State Management (BLoC / Cubit)
The project must use:
●	AuthCubit (authentication logic)
●	PostCubit (posts management)
●	ApiCubit (API data handling)
4.7 Local Storage (SharedPreferences)
Used for storing:
●	username
●	selected theme
●	selected language
4.8 Localization
The application must support 3 languages:
●	🇰🇿 Kazakh
●	🇷🇺 Russian
●	🇬🇧 English
 4.9 Animations
●	smooth post appearance animation
●	like button animation (scale effect)
●	page transition animations
4.10 Profile Screen
The profile screen includes:
●	user email
●	username
●	list of user posts
●	logout button


5. Navigation (BottomNavigationBar)
The application contains 4 main tabs:
1.	Feed – posts feed
2.	Create – create new post
3.	Explore – API content
4.	Profile – user profile
6. UI Requirements
●	modern and clean UI design
●	consistent color scheme (using constants)
●	responsive layout
●	reusable widgets
●	support for dark and light themes
7.  Technical Requirements
The project must use:
●	Flutter SDK
●	Firebase Authentication - 5
●	Cloud Firestore - 5
●	BLoC / Cubit state management - 10
●	Dio / Retrofit for API requests - 5
●	SharedPreferences - 5
●	Flutter Localization - 5
Total: 35

