# Rails Lite
[Amazon Web Services link][heroku]

[heroku]: https://enigmatic-sierra-3429.herokuapp.com

# Overview
This is a web application backed by a database inspired by Rails. The server provides RESTful HTTP routes which allow visitors to create cats, view cats, or browse an index of cats. Additionally, some of the basic Rails functionality such as flash and params have been implemented.

The live version is currently hosted hosted by Amazon Web Services on an EC2 micro instance. The database for the server is SQLite3, with a custom ORM.

# Server

# Router

# Controller

# DB

# ORM

<!-- This is a Markdown checklist. Use it to keep track of your progress! -->

- [X] Create accounts
- [X] Create sessions (log in)
- [X] Create groups
- [ ] Create events
- [X] View groups and events
- [ ] Subscribe to groups
- [ ] RSVP to events
- [ ] View subscribed Groups
- [ ] Edit Events
- [ ] Edit Groups
- [ ] Comment on Event
- [ ] Add calendar view

## Design Docs
* [View Wireframes][views]
* [DB schema][schema]

[views]: ./docs/views.md
[schema]: ./docs/schema.md

## Implementation Timeline

### Phase 1: User Authentication, Group and Event Creation (~1 day)
I will implement user authentication in Rails based on the practices learned at
App Academy. This phase will allow users to create groups and events and visit rudimentary pages with each of these resources. The app will be pushed to Heroku before continuing.

[Details][phase-one]

### Phase 2: Viewing Groups and Events (~2 days)
I will add API routes which will render json and parse out association data. With the JSON data I will be able to display individual show pages for groups and events as well as display indeces of both. I will also finish the user show page to display all of the groups a user belongs to.

[Details][phase-two]

### Phase 3: Editing and Displaying Groups and Events (~2 days)
I will create forms for creating and editing groups and events. Successful submission of these forms redirects the user to the created resource's show page. As a bonus, I will add Filepicker to enable user upload of images for profile pics and groups.

[Details][phase-three]

### Phase 4: Comments and Event Feed (~1-2 days)
I'll add a Comment model which will allow users to comment on events and I will create a Backbone view to display comments on an individual event show page. Additionally, I will create an events feed which will be displayed in place of the groups index which shows upcoming events for groups the user subscribes to.

[Details][phase-four]

### Phase 5: Calendar Views (~2 days)
I'll add a calendar view tab to the group show page which has a calendar display with each of the upcoming and past events on the calendar pane.

[Details][phase-five]

### Bonus Features (TBD)
- [ ] Create tags and allow tags to belong to both users and groups
- [ ] Add pictures for blogs and users

[phase-one]: ./docs/phases/phase1.md
[phase-two]: ./docs/phases/phase2.md
[phase-three]: ./docs/phases/phase3.md
[phase-four]: ./docs/phases/phase4.md
[phase-five]: ./docs/phases/phase5.md
