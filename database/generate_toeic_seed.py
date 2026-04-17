from pathlib import Path


OUT = Path(__file__).with_name("seed_toeic_full_test_200.sql")


def esc(value):
    if value is None:
        return "NULL"
    return "'" + str(value).replace("'", "''") + "'"


rows = []


def add_question(
    *,
    part,
    section,
    group_key=None,
    question_order=1,
    instructions=None,
    shared_content=None,
    shared_audio_url=None,
    shared_image_url=None,
    content,
    option_a,
    option_b,
    option_c,
    option_d,
    correct_answer,
    explanation=None,
    audio_url=None,
    image_url=None,
):
    rows.append(
        {
            "part": part,
            "section": section,
            "group_key": group_key,
            "question_order": question_order,
            "instructions": instructions,
            "shared_content": shared_content,
            "shared_audio_url": shared_audio_url,
            "shared_image_url": shared_image_url,
            "content": content,
            "option_a": option_a,
            "option_b": option_b,
            "option_c": option_c,
            "option_d": option_d,
            "correct_answer": correct_answer,
            "explanation": explanation,
            "audio_url": audio_url,
            "image_url": image_url,
        }
    )


part1 = [
    (
        "A photographer is adjusting a camera on a tripod.",
        "Two customers are browsing in a bookstore.",
        "A server is carrying drinks to a table.",
        "A mechanic is checking a tire gauge.",
        "A",
        "The picture focuses on a photographer preparing a camera on a tripod.",
    ),
    (
        "Several employees are seated around a conference table.",
        "A chef is placing bread in an oven.",
        "A passenger is locking a suitcase.",
        "A cyclist is crossing a narrow bridge.",
        "A",
        "The people are gathered around a conference table.",
    ),
    (
        "A woman is watering plants inside a greenhouse.",
        "A cashier is scanning a customer card.",
        "A child is painting a fence.",
        "A waiter is folding napkins.",
        "A",
        "The woman is watering plants in a greenhouse setting.",
    ),
    (
        "Boxes are being loaded onto a delivery truck.",
        "A pilot is speaking to passengers.",
        "A clerk is hanging coats in a closet.",
        "A group is watching a movie screen.",
        "A",
        "The scene shows boxes being loaded onto a truck.",
    ),
    (
        "A man is repairing a computer in an office.",
        "A shopper is trying on a jacket.",
        "A barista is grinding coffee beans.",
        "A musician is tuning a violin.",
        "A",
        "The man is working on a computer in an office.",
    ),
    (
        "Some bicycles are parked beside a building.",
        "A gardener is trimming a hedge.",
        "A technician is replacing ceiling lights.",
        "People are boarding a ferry.",
        "A",
        "The most accurate description is that bicycles are parked beside a building.",
    ),
]

for a, b, c, d, answer, explanation in part1:
    add_question(
        part=1,
        section="listening",
        instructions="Part 1: Listen to the statements and choose the sentence that best describes the picture.",
        content="Look at the picture and choose the best description.",
        option_a=a,
        option_b=b,
        option_c=c,
        option_d=d,
        correct_answer=answer,
        explanation=explanation,
    )


part2 = [
    ("Where should the visitors wait?", "In the reception area.", "At half past two.", "With the blue folders.", "Because the manager is busy."),
    ("Who approved the budget revision?", "The finance director did.", "During the morning commute.", "At the branch office.", "A revised schedule."),
    ("Why is the printer offline?", "It ran out of paper.", "Next to the supply closet.", "A color brochure.", "For tomorrow's event."),
    ("When will the shipment arrive?", "Early Friday morning.", "On the loading dock.", "A delivery receipt.", "Because of traffic."),
    ("How do I access the staff portal?", "Use your employee ID and password.", "It was updated last week.", "From the IT department.", "Near the front entrance."),
    ("Where did Ms. Gomez put the contract?", "On your desk this morning.", "For six more months.", "With the legal team.", "Because it needs a signature."),
    ("Why was the meeting postponed?", "Several team members were traveling.", "At the downtown office.", "An updated sales chart.", "For the new interns."),
    ("Who is giving the presentation today?", "Mr. Harris from marketing.", "In the main auditorium.", "A slide deck about exports.", "At three-thirty exactly."),
    ("When does the cafeteria close?", "At seven in the evening.", "Beside the copy room.", "A bowl of soup, please.", "Because the chef is away."),
    ("How often are expense reports reviewed?", "Usually once a month.", "By the elevator lobby.", "An accounting software update.", "After the trade fair."),
    ("Which department handles returns?", "Customer service does.", "On the third floor.", "A larger storage cabinet.", "By courier yesterday."),
    ("Why did the technician visit the warehouse?", "To inspect the cooling system.", "At the loading entrance.", "A pair of safety gloves.", "With the night supervisor."),
    ("Where can I find the training manual?", "It is saved on the shared drive.", "For the new schedule.", "In about ten minutes.", "By the accounting staff."),
    ("Who will meet the client at the airport?", "Natalie will pick him up.", "At the arrival gate.", "A company brochure.", "Because the flight was delayed."),
    ("How long will the audit take?", "About three business days.", "In the archive room.", "A revised checklist.", "With the external consultant."),
    ("When was the software patch installed?", "Late last night.", "On the office laptop.", "A faster internet plan.", "Before the annual dinner."),
    ("Why are the lights still on in Conference Room B?", "The cleaning crew is still there.", "By the glass entrance.", "A stack of brochures.", "At the end of the hallway."),
    ("Who can sign this purchase request?", "The operations manager can.", "At the front counter.", "A packet of invoices.", "Before the supplier arrives."),
    ("Where is the nearest parking garage?", "Across from the bank.", "At eleven-fifteen.", "A silver sedan.", "Because the lot is full."),
    ("How many copies should I print?", "Please make ten copies.", "Near the reception desk.", "A color printer.", "For the welcome packets."),
    ("Why did the courier call?", "To confirm the delivery address.", "At the security desk.", "A signed receipt.", "By express train."),
    ("Who is responsible for the new website design?", "An outside agency is.", "In the top drawer.", "About two weeks ago.", "A larger monitor."),
    ("When are the interns starting?", "They begin next Monday.", "At the side entrance.", "A welcome speech.", "Because orientation was canceled."),
    ("How was the conference in Busan?", "It was very productive.", "At the harbor district.", "A printed itinerary.", "For the regional managers."),
    ("Where should these sample products be stored?", "Put them in the display cabinet.", "At the quarterly review.", "A red shipping label.", "Because the shelf is broken."),
]

for content, a, b, c, d in part2:
    add_question(
        part=2,
        section="listening",
        instructions="Part 2: Listen to the question or statement and choose the best response.",
        content=content,
        option_a=a,
        option_b=b,
        option_c=c,
        option_d=d,
        correct_answer="A",
        explanation="Choose the response that most naturally answers the question.",
    )


part3_sets = [
    (
        "P3_SET_01",
        "Questions 32-34 refer to the following conversation.\n\nWoman: Daniel, have the brochures for the Osaka trade show arrived yet?\nMan: Yes, they were delivered this morning, but the display banners are still missing.\nWoman: Then please call the printer and ask whether they can bring the banners before noon.",
        [
            ("What are the speakers mainly discussing?", "Materials for a trade show.", "A delayed flight itinerary.", "A hotel reservation.", "A hiring decision."),
            ("What has already arrived?", "The brochures.", "The display banners.", "The catering order.", "The name badges."),
            ("What does the woman ask the man to do?", "Call the printer.", "Book a taxi.", "Edit the brochure text.", "Meet a client at noon."),
        ],
    ),
    (
        "P3_SET_02",
        "Questions 35-37 refer to the following conversation.\n\nMan: Hi, Elena. I reviewed your draft of the monthly report.\nWoman: Great. Is there anything else I should add before I send it to the director?\nMan: Please include the updated sales chart on page four and then email the final version to me.",
        [
            ("What are the speakers talking about?", "A monthly report.", "An office renovation.", "A training session.", "A delivery route."),
            ("What should the woman add?", "An updated sales chart.", "A conference schedule.", "A budget request.", "A customer survey."),
            ("What will the woman probably do next?", "Send the final version by email.", "Visit page four of a website.", "Call the director directly.", "Print new business cards."),
        ],
    ),
    (
        "P3_SET_03",
        "Questions 38-40 refer to the following conversation.\n\nWoman: The coffee machine on the third floor is out of order again.\nMan: I noticed that this morning. The maintenance company said a technician can come tomorrow.\nWoman: Okay, I'll post a notice in the break room so everyone knows to use the first-floor kitchen today.",
        [
            ("What problem do the speakers mention?", "A broken coffee machine.", "A delayed lunch order.", "A missing key card.", "A canceled meeting room booking."),
            ("When can the technician come?", "Tomorrow.", "This afternoon.", "Next week.", "In an hour."),
            ("What will the woman do?", "Post a notice.", "Call the security desk.", "Order bottled water.", "Move the machine downstairs."),
        ],
    ),
    (
        "P3_SET_04",
        "Questions 41-43 refer to the following conversation.\n\nMan: Have you finished checking the guest list for Friday's banquet?\nWoman: Almost. Two company names were misspelled, so I'm correcting them now.\nMan: Good. Once you're done, please forward the list to the catering manager.",
        [
            ("What event are the speakers preparing for?", "A banquet.", "A product launch video.", "A warehouse tour.", "A job fair."),
            ("What is the woman doing now?", "Correcting misspelled names.", "Calling the catering manager.", "Booking a conference hall.", "Designing invitation cards."),
            ("What should happen after the corrections are made?", "The list should be forwarded to the catering manager.", "The banquet should be postponed.", "The menu should be printed.", "The guests should be called individually."),
        ],
    ),
    (
        "P3_SET_05",
        "Questions 44-46 refer to the following conversation.\n\nWoman: I'm looking for the conference badge printer.\nMan: It's in the registration area near the main entrance.\nWoman: Thanks. I need to print badges for three late attendees before the keynote starts.",
        [
            ("Where does the conversation most likely take place?", "At a conference venue.", "At a post office.", "At a train station.", "At a restaurant kitchen."),
            ("Where is the badge printer?", "Near the main entrance.", "Inside the storage room.", "Next to the keynote stage.", "On the second floor."),
            ("Why does the woman need the printer?", "To print badges for late attendees.", "To prepare meal vouchers.", "To make copies of a contract.", "To replace a damaged poster."),
        ],
    ),
    (
        "P3_SET_06",
        "Questions 47-49 refer to the following conversation.\n\nMan: Did the supplier send the replacement parts?\nWoman: Yes, but only half of the order was included.\nMan: Then I'll call them and ask for the remaining parts to be sent by express delivery.",
        [
            ("What did the supplier send?", "Replacement parts.", "Employee uniforms.", "A payment receipt.", "Promotional leaflets."),
            ("What problem is mentioned?", "Only half of the order arrived.", "The shipment was sent to the wrong city.", "The boxes were empty.", "The price was too high."),
            ("What will the man do?", "Request express delivery for the rest.", "Cancel the entire order.", "Pick up the parts himself.", "Return the delivered items."),
        ],
    ),
    (
        "P3_SET_07",
        "Questions 50-52 refer to the following conversation.\n\nWoman: Are you still planning to attend the training session this afternoon?\nMan: Yes, but I may be a few minutes late because I have to meet a client first.\nWoman: No problem. I'll save you a seat near the front.",
        [
            ("What are the speakers discussing?", "A training session.", "A hotel checkout time.", "A sales target.", "A new software license."),
            ("Why might the man be late?", "He has to meet a client.", "His train was canceled.", "He needs to print materials.", "He is waiting for a parcel."),
            ("What does the woman offer to do?", "Save a seat.", "Reschedule the session.", "Send the client a message.", "Bring refreshments."),
        ],
    ),
    (
        "P3_SET_08",
        "Questions 53-55 refer to the following conversation.\n\nMan: I'm having trouble logging into the inventory system.\nWoman: Did you reset your password after the security update?\nMan: Not yet. I'll do that now and try again before I contact IT.",
        [
            ("What problem does the man have?", "He cannot log into a system.", "He lost a package.", "He missed a deadline.", "He forgot a meeting location."),
            ("What does the woman mention?", "A security update.", "A delayed audit.", "A new office layout.", "A client complaint."),
            ("What will the man do first?", "Reset his password.", "Call the IT manager.", "Replace his laptop.", "Update the inventory count."),
        ],
    ),
    (
        "P3_SET_09",
        "Questions 56-58 refer to the following conversation.\n\nWoman: The design team wants feedback on the new package label.\nMan: I like the color scheme, but the product name should be larger.\nWoman: I agree. I'll send that suggestion before the review meeting starts.",
        [
            ("What are the speakers giving feedback on?", "A package label.", "A parking plan.", "A travel reimbursement form.", "A customer invoice."),
            ("What does the man suggest changing?", "Make the product name larger.", "Use a different shipping company.", "Add a second barcode.", "Lower the price."),
            ("What will the woman do?", "Send the suggestion before the review meeting.", "Meet the design team tomorrow.", "Print the labels immediately.", "Cancel the review meeting."),
        ],
    ),
    (
        "P3_SET_10",
        "Questions 59-61 refer to the following conversation.\n\nMan: We need one more volunteer for the museum fundraising event.\nWoman: I can help at the registration desk from noon until three.\nMan: Perfect. I'll add your name to the schedule and email you the instructions.",
        [
            ("What event are the speakers discussing?", "A fundraising event.", "A warehouse inspection.", "A lecture series.", "A product recall."),
            ("What will the woman do?", "Work at the registration desk.", "Design the event poster.", "Collect parking fees.", "Deliver museum exhibits."),
            ("What will the man send by email?", "Instructions.", "A donation receipt.", "A map of the museum.", "A revised budget."),
        ],
    ),
    (
        "P3_SET_11",
        "Questions 62-64 refer to the following conversation.\n\nWoman: Have you seen the prototype for the folding chair?\nMan: Yes, and the engineering team wants to test a lighter material.\nWoman: That should reduce shipping costs, so let's mention it in tomorrow's planning meeting.",
        [
            ("What product do the speakers mention?", "A folding chair.", "A tablet computer.", "A coffee grinder.", "A storage cabinet."),
            ("What does the engineering team want to test?", "A lighter material.", "A new advertising slogan.", "A larger warehouse.", "A lower retail price."),
            ("Why does the woman support the idea?", "It should reduce shipping costs.", "It will shorten the meeting.", "It improves employee morale.", "It requires less training."),
        ],
    ),
    (
        "P3_SET_12",
        "Questions 65-67 refer to the following conversation.\n\nMan: Did you reserve the van for tomorrow's site visit?\nWoman: Yes, but we need to return it by 5 p.m. because another team booked it for the evening.\nMan: That's fine. We should be back well before then.",
        [
            ("Why do the speakers need a van?", "For a site visit.", "For an office move.", "For a client banquet.", "For a museum tour."),
            ("What limitation does the woman mention?", "The van must be returned by 5 p.m.", "The van can only hold four people.", "The driver is unavailable.", "The fuel tank is empty."),
            ("What does the man say about the schedule?", "They should return before 5 p.m.", "They will leave later in the day.", "They need a second van.", "They will cancel the visit."),
        ],
    ),
    (
        "P3_SET_13",
        "Questions 68-70 refer to the following conversation.\n\nWoman: The accountant asked for your signed travel claim form.\nMan: I thought I submitted it yesterday.\nWoman: The form was missing your signature, so I left it on your chair for you to complete this morning.",
        [
            ("What document is being discussed?", "A travel claim form.", "A delivery invoice.", "A performance review.", "A parking permit."),
            ("What was missing from the form?", "A signature.", "A mailing address.", "A tax code.", "A payment date."),
            ("Where did the woman leave the form?", "On the man's chair.", "At the front desk.", "In the accountant's office.", "Inside the meeting room."),
        ],
    ),
]

for group_key, transcript, qs in part3_sets:
    for order, (content, a, b, c, d) in enumerate(qs, 1):
        add_question(
            part=3,
            section="listening",
            group_key=group_key,
            question_order=order,
            instructions="Part 3: Listen to the conversation and answer the questions.",
            shared_content=transcript,
            content=content,
            option_a=a,
            option_b=b,
            option_c=c,
            option_d=d,
            correct_answer="A",
            explanation="Use the details in the conversation to choose the best answer.",
        )


part4_sets = [
    (
        "P4_SET_01",
        "Questions 71-73 refer to the following talk.\n\nGood morning, passengers. Train 204 to Daejeon will depart from platform 6 instead of platform 4 because of track maintenance. The departure time remains 8:15, and station staff are available if you need directions.",
        [
            ("What is the announcement mainly about?", "A platform change.", "A ticket discount.", "A weather delay.", "A lost item report."),
            ("Why was the platform changed?", "Because of track maintenance.", "Because the train arrived late.", "Because the station is crowded.", "Because the conductor is absent."),
            ("What time will the train depart?", "At 8:15.", "At 6:00.", "At 4:20.", "At 8:50."),
        ],
    ),
    (
        "P4_SET_02",
        "Questions 74-76 refer to the following announcement.\n\nThis is a reminder that the downtown fitness center will close at 6 p.m. today for equipment cleaning. Members who normally attend evening classes may use the Riverside branch at no extra charge.",
        [
            ("What business is making the announcement?", "A fitness center.", "A bank.", "A bookstore.", "A shipping company."),
            ("Why will it close early?", "For equipment cleaning.", "For a staff party.", "For inventory counting.", "For a power outage."),
            ("What can members do?", "Use another branch.", "Receive a refund.", "Enroll in free training.", "Park behind the building."),
        ],
    ),
    (
        "P4_SET_03",
        "Questions 77-79 refer to the following recorded message.\n\nHello, this is the City Dental Clinic calling to remind you of your appointment with Dr. Han on Thursday at 10 a.m. If you need to change your appointment time, please call our office before 5 p.m. on Wednesday.",
        [
            ("Who is the message for?", "A patient.", "A supplier.", "A building manager.", "A delivery driver."),
            ("When is the appointment?", "Thursday at 10 a.m.", "Wednesday at 5 p.m.", "Thursday at 5 p.m.", "Friday at 10 a.m."),
            ("What should the listener do to change the appointment?", "Call before 5 p.m. on Wednesday.", "Reply by email.", "Visit the clinic in person.", "Call after the appointment."),
        ],
    ),
    (
        "P4_SET_04",
        "Questions 80-82 refer to the following excerpt from a talk.\n\nAs part of our orientation program, all new employees must complete safety training during their first week. The training room is on the second floor beside Human Resources, and the session begins at 9:30 each morning.",
        [
            ("Who is the talk intended for?", "New employees.", "Building inspectors.", "Visiting clients.", "Security guards only."),
            ("Where is the training room?", "Beside Human Resources.", "On the ground floor.", "Near the cafeteria.", "Across from the parking garage."),
            ("When does the session begin?", "At 9:30 each morning.", "At 8:00 each morning.", "Every Monday at noon.", "On the first Friday of the month."),
        ],
    ),
    (
        "P4_SET_05",
        "Questions 83-85 refer to the following advertisement.\n\nLooking for a quick lunch near Central Station? Visit Green Bowl Cafe for fresh salads, sandwiches, and soup. This week only, customers who show a train ticket can receive a free drink with any meal purchase.",
        [
            ("What is being advertised?", "A cafe.", "A travel agency.", "A supermarket.", "A repair shop."),
            ("Where is the cafe located?", "Near Central Station.", "Inside a bookstore.", "At the city airport.", "Across from the museum."),
            ("What special offer is mentioned?", "A free drink with a meal purchase.", "Half-price train tickets.", "Free parking for a month.", "A discount on salads only."),
        ],
    ),
    (
        "P4_SET_06",
        "Questions 86-88 refer to the following weather report.\n\nThe weather for the east coast will remain sunny through most of the afternoon, but strong winds are expected after 6 p.m. Small fishing boats are advised to return to shore before the evening weather changes.",
        [
            ("What is the report mainly about?", "Weather conditions.", "A harbor expansion.", "A fishing competition.", "A delayed ferry route."),
            ("When are strong winds expected?", "After 6 p.m.", "Before noon.", "At sunrise.", "Tomorrow morning."),
            ("Who is advised to return early?", "Small fishing boats.", "Train passengers.", "Delivery trucks.", "Museum visitors."),
        ],
    ),
    (
        "P4_SET_07",
        "Questions 89-91 refer to the following voicemail.\n\nHi, Karen. This is Paul from Bright Print. Your order of 2,000 catalogues is ready for pickup. We are open until 7 tonight, but if that is inconvenient, we can deliver the boxes to your office tomorrow morning.",
        [
            ("Why is Paul calling?", "To say an order is ready.", "To request a design file.", "To cancel a contract.", "To confirm a payment error."),
            ("What business does Paul work for?", "A printing company.", "A law office.", "A travel service.", "A furniture store."),
            ("What alternative does Paul offer?", "Delivery tomorrow morning.", "A refund this afternoon.", "A larger order discount.", "Pickup at a warehouse."),
        ],
    ),
    (
        "P4_SET_08",
        "Questions 92-94 refer to the following announcement.\n\nThe museum's modern art gallery will reopen this Saturday after a two-week renovation. To celebrate, guided tours will be offered every hour between 10 a.m. and 3 p.m., and members may bring one guest free of charge.",
        [
            ("What place is being discussed?", "A museum gallery.", "A concert hall.", "A library archive.", "A sports arena."),
            ("Why had it been closed?", "For renovation.", "For inventory checks.", "For staff training.", "For a private event."),
            ("What benefit do members receive?", "They may bring one guest free.", "They receive a free lunch.", "They can attend a private concert.", "They may park without charge."),
        ],
    ),
    (
        "P4_SET_09",
        "Questions 95-97 refer to the following radio report.\n\nCity officials announced that Oak Street will be closed to traffic this weekend while workers replace old water pipes. Drivers should follow the posted detour signs and allow extra travel time when heading downtown.",
        [
            ("What will happen on Oak Street?", "It will be closed to traffic.", "A new bus route will open.", "Parking fees will increase.", "A food festival will be held."),
            ("Why is the street being closed?", "Workers are replacing water pipes.", "A parade is scheduled.", "A building is being painted.", "The road surface is icy."),
            ("What are drivers advised to do?", "Follow detour signs.", "Travel only at night.", "Use public parking garages.", "Avoid carrying heavy items."),
        ],
    ),
    (
        "P4_SET_10",
        "Questions 98-100 refer to the following telephone message.\n\nHello, this is an automated call from SkyView Hotel. We are contacting guests arriving this evening to let them know that road construction near the main entrance may cause delays. Valet staff will be stationed at the east gate to assist with luggage.",
        [
            ("Who is sending the message?", "A hotel.", "A delivery service.", "An airline.", "A bank."),
            ("What may cause delays?", "Road construction.", "Heavy rain.", "A power failure.", "A ticket inspection."),
            ("Where will staff help guests?", "At the east gate.", "In the parking basement.", "At the front desk only.", "Near the restaurant entrance."),
        ],
    ),
]

for group_key, transcript, qs in part4_sets:
    for order, (content, a, b, c, d) in enumerate(qs, 1):
        add_question(
            part=4,
            section="listening",
            group_key=group_key,
            question_order=order,
            instructions="Part 4: Listen to the talk and answer the questions.",
            shared_content=transcript,
            content=content,
            option_a=a,
            option_b=b,
            option_c=c,
            option_d=d,
            correct_answer="A",
            explanation="Choose the answer supported by the short talk.",
        )


part5 = [
    ("Ms. Lopez is responsible ____ updating the client database each week.", "for", "to", "with", "by"),
    ("The new marketing assistant will begin work ____ Monday morning.", "on", "during", "until", "among"),
    ("Please submit your travel receipts ____ the end of the month.", "by", "among", "into", "across"),
    ("The conference room is unavailable today, so the meeting has been ____.", "rescheduled", "reschedule", "rescheduling", "reschedules"),
    ("Customers are asked to keep their receipts ____ they need to exchange an item.", "in case", "such as", "even though", "as if"),
    ("The finance team reviewed the proposal carefully before ____ it.", "approving", "approve", "approved", "approves"),
    ("Because the elevator is under repair, employees should use the stairs ____.", "instead", "already", "still", "only"),
    ("The manager requested a copy of the contract ____ signed by both companies.", "that was", "what is", "who were", "where being"),
    ("Our supplier offered a discount because we ordered a ____ quantity of paper.", "large", "largely", "larger", "largestly"),
    ("If you have any questions about the software, please contact the IT help desk ____.", "directly", "direct", "direction", "directness"),
    ("The museum will remain open late ____ the summer festival.", "during", "between", "among", "beneath"),
    ("All visitors must wear identification badges while they are ____ the factory.", "inside", "along", "onto", "beside"),
    ("The warranty covers parts and labor ____ one full year after purchase.", "for", "since", "throughout of", "toward"),
    ("Mr. Chen asked whether the final report had been ____ to the board yet.", "sent", "send", "sending", "sends"),
    ("The restaurant became popular quickly because of its excellent service and ____ location.", "convenient", "convenience", "conveniently", "convening"),
    ("Please place completed forms in the tray ____ the copy machine.", "beside", "between", "towarding", "through"),
    ("The equipment manual is written clearly so that new employees can follow it ____.", "easily", "easy", "easier", "ease"),
    ("The director was pleased ____ the sales team exceeded its quarterly goal.", "that", "what", "whether of", "than"),
    ("Any employee who works overtime must receive prior ____ from a supervisor.", "approval", "approve", "approved", "approving"),
    ("The shipment was delayed ____ severe weather near the port.", "because of", "in spite", "as soon", "instead of"),
    ("The guide recommended that we ____ the museum before lunch to avoid the crowds.", "visit", "visited", "visiting", "visitor"),
    ("The seminar attracted managers from Seoul, Busan, and several ____ cities.", "other", "another", "others", "the other one"),
    ("After reviewing the budget, the committee decided to postpone the project ____.", "temporarily", "temporary", "tempers", "temporariness"),
    ("Employees are reminded not to share passwords ____ anyone outside the company.", "with", "from", "under", "about"),
    ("The advertising campaign was successful ____ it targeted young professionals.", "because", "unless", "despite", "whereas of"),
    ("Please note that the cafeteria accepts credit cards but not personal ____.", "checks", "checking", "checker", "checked"),
    ("The maintenance crew will inspect the air-conditioning units ____ the weekend.", "over", "since", "among", "beneath"),
    ("Our branch office has hired two consultants who specialize in tax ____.", "law", "lawful", "lawsuit", "legally"),
    ("The customer service team responded so ____ that the complaint was resolved in one day.", "quickly", "quick", "quicker", "quickness"),
    ("The factory will expand production next year if demand continues to ____.", "increase", "increased", "increasingly", "increaser"),
]

for content, a, b, c, d in part5:
    add_question(
        part=5,
        section="reading",
        instructions="Part 5: Choose the word or phrase that best completes the sentence.",
        content=content,
        option_a=a,
        option_b=b,
        option_c=c,
        option_d=d,
        correct_answer="A",
        explanation="Select the option that is grammatically and logically correct.",
    )


part6_sets = [
    ("P6_SET_01", "Questions 131-132 refer to the following text.\n\nTo: All Staff\nSubject: Lobby renovation\n\nBeginning next Tuesday, the main lobby will be partially closed while new flooring is ____. Employees should enter through the east doors and allow extra ____ in the morning. We expect the work to be completed by Friday evening, and the lobby will reopen on Monday.", [("Select the best word for Blank 1: Beginning next Tuesday, the main lobby will be partially closed while new flooring is ____.", "installed", "install", "installing", "installs"), ("Select the best word for Blank 2: Employees should enter through the east doors and allow extra ____ in the morning.", "time", "times", "timely", "timed")]),
    ("P6_SET_02", "Questions 133-134 refer to the following text.\n\nThank you for registering for the Small Business Finance Workshop. The event will be held in Hall B on June 18, and check-in ____ at 8:30 a.m. Participants are encouraged to bring a notebook and a copy of the program schedule that was ____ last week.", [("Select the best word for Blank 1: The event will be held in Hall B on June 18, and check-in ____ at 8:30 a.m.", "starts", "start", "starting", "starter"), ("Select the best word for Blank 2: Participants are encouraged to bring a notebook and a copy of the program schedule that was ____ last week.", "emailed", "email", "emails", "emailing")]),
    ("P6_SET_03", "Questions 135-136 refer to the following text.\n\nThe Green Market has expanded its delivery area to include the northern suburbs. Orders placed before noon will arrive the same day, while later orders will be delivered the following ____. Customers can review the updated service map on the company ____.", [("Select the best word for Blank 1: Orders placed before noon will arrive the same day, while later orders will be delivered the following ____.", "morning", "mornings", "morningly", "morn"), ("Select the best word for Blank 2: Customers can review the updated service map on the company ____.", "website", "web", "siteful", "webbed")]),
    ("P6_SET_04", "Questions 137-138 refer to the following text.\n\nPlease be advised that our customer support phone line will be unavailable from 1 p.m. to 2 p.m. today because of a system ____. During that time, inquiries may still be submitted through the online help form, and responses will be sent as soon as service ____.", [("Select the best word for Blank 1: Our customer support phone line will be unavailable from 1 p.m. to 2 p.m. today because of a system ____.", "upgrade", "upgraded", "upgrades", "upgradingly"), ("Select the best word for Blank 2: Responses will be sent as soon as service ____.", "resumes", "resume", "resumed", "resuming")]),
    ("P6_SET_05", "Questions 139-140 refer to the following text.\n\nVisitors to the History Museum are invited to join a guided tour of the new photography exhibition. Tours begin every hour at the information desk on the ____ floor. Because space is limited, guests are advised to ____ a place online before arriving.", [("Select the best word for Blank 1: Tours begin every hour at the information desk on the ____ floor.", "first", "one", "single", "initially"), ("Select the best word for Blank 2: Because space is limited, guests are advised to ____ a place online before arriving.", "reserve", "reserved", "reserving", "reservation")]),
    ("P6_SET_06", "Questions 141-142 refer to the following text.\n\nThe Lakeside Hotel is pleased to announce the completion of its rooftop garden. Hotel guests may now enjoy breakfast there on weekends, weather ____. Reservations are recommended because the seating area is ____ than the main dining room.", [("Select the best word for Blank 1: Hotel guests may now enjoy breakfast there on weekends, weather ____.", "permitting", "permit", "permitted", "permits"), ("Select the best word for Blank 2: Reservations are recommended because the seating area is ____ than the main dining room.", "smaller", "small", "smallest", "smalling")]),
    ("P6_SET_07", "Questions 143-144 refer to the following text.\n\nAs part of our annual safety review, employees must update their emergency contact information by ____. The form can be accessed through the internal website and should be completed by all full-time and ____ staff.", [("Select the best word for Blank 1: Employees must update their emergency contact information by ____.", "July 31", "small", "desk", "carefully"), ("Select the best word for Blank 2: The form can be accessed through the internal website and should be completed by all full-time and ____ staff.", "part-time", "partly time", "timing part", "partial")]),
    ("P6_SET_08", "Questions 145-146 refer to the following text.\n\nThank you for shopping at North Point Books. Customers who spend more than $50 in one visit are ____ for a discount on their next purchase. Ask for a membership card at the register to receive promotional emails and event ____.", [("Select the best word for Blank 1: Customers who spend more than $50 in one visit are ____ for a discount on their next purchase.", "eligible", "eligibly", "eligibility", "elective"), ("Select the best word for Blank 2: Ask for a membership card at the register to receive promotional emails and event ____.", "invitations", "invites", "inviting", "inviteful")]),
]

for group_key, passage, qs in part6_sets:
    for order, (content, a, b, c, d) in enumerate(qs, 1):
        add_question(
            part=6,
            section="reading",
            group_key=group_key,
            question_order=order,
            instructions="Part 6: Read the text and choose the best answer for each blank.",
            shared_content=passage,
            content=content,
            option_a=a,
            option_b=b,
            option_c=c,
            option_d=d,
            correct_answer="A",
            explanation="Use context and grammar to complete the text.",
        )


part7_sets = [
    ("P7_SET_01", "Questions 147-149 refer to the following notice.\n\nNotice to Residents\nThe apartment management office will inspect all smoke detectors on Wednesday between 1 p.m. and 4 p.m. Residents do not need to be home, but pets should be secured. Please contact the office if your unit will be unavailable during that time.", [("What is the purpose of the notice?", "To announce smoke detector inspections.", "To advertise an apartment for rent.", "To explain a rent increase.", "To invite residents to a meeting."), ("When will the inspections take place?", "Wednesday afternoon.", "Wednesday morning.", "Thursday afternoon.", "Friday evening."), ("What are residents asked to do?", "Secure their pets.", "Pay a maintenance fee.", "Move out temporarily.", "Visit the management office.")]),
    ("P7_SET_02", "Questions 150-152 refer to the following email.\n\nFrom: Nina Park\nTo: Sales Team\nSubject: Regional client visit\n\nI will be visiting our Daegu clients next Thursday and Friday. If you have any updated product sheets or pricing lists that should be shared, please send them to me by Tuesday noon so I can include them in my presentation packet.", [("Why is Nina writing the email?", "To request updated sales materials.", "To cancel a trip.", "To announce a promotion.", "To invite staff to lunch."), ("When will Nina visit the clients?", "Next Thursday and Friday.", "This Tuesday.", "Tomorrow afternoon.", "At the end of the month."), ("What does Nina want by Tuesday noon?", "Product sheets or pricing lists.", "Hotel reservations.", "Expense receipts.", "Staff attendance reports.")]),
    ("P7_SET_03", "Questions 153-155 refer to the following article.\n\nCity Bike Share Expands\nThe City Bike Share program added 12 new stations this month, including three near university campuses. Officials say the expansion is intended to reduce traffic congestion and encourage more residents to use public transit for part of their daily commute.", [("What was added this month?", "Twelve new bike stations.", "Three new train lines.", "A parking garage.", "A highway toll system."), ("Where are some of the new stations located?", "Near university campuses.", "Inside shopping malls.", "At the airport.", "Beside the harbor."), ("Why was the program expanded?", "To reduce congestion and encourage transit use.", "To raise parking fees.", "To support a bicycle race.", "To close older stations.")]),
    ("P7_SET_04", "Questions 156-158 refer to the following advertisement.\n\nLooking for office furniture at a lower price? Modern Workspace is offering 20 percent off all desks and shelving units through May 31. Free assembly is included for purchases over $500, and delivery is available throughout the capital region.", [("What is being advertised?", "Office furniture.", "A software package.", "A moving service.", "A design course."), ("How long does the discount last?", "Through May 31.", "For one weekend only.", "Until the end of the year.", "Until inventory is counted."), ("What is included for purchases over $500?", "Free assembly.", "A warranty extension.", "A free computer chair.", "Same-day pickup.")]),
    ("P7_SET_05", "Questions 159-161 refer to the following webpage.\n\nHarbor Museum Hours\nTuesday-Friday: 10 a.m.-6 p.m.\nSaturday-Sunday: 9 a.m.-7 p.m.\nClosed Mondays\nSpecial family workshops are held on the second Saturday of each month. Tickets can be purchased online or at the front desk.", [("When is the museum closed?", "On Mondays.", "On Tuesdays.", "Every weekend.", "Only on holidays."), ("When are family workshops held?", "On the second Saturday of each month.", "Every Friday afternoon.", "Every Sunday morning.", "Once a year."), ("How can tickets be purchased?", "Online or at the front desk.", "By phone only.", "From nearby shops.", "At the parking gate.")]),
    ("P7_SET_06", "Questions 162-164 refer to the following memo.\n\nTo: All Branch Managers\nPlease remind employees that inventory counts must be submitted by 6 p.m. each Friday. Branches that are using the new reporting software should attach both the digital spreadsheet and the summary checklist to the weekly email.", [("What must be submitted by Friday evening?", "Inventory counts.", "Travel claims.", "Store keys.", "Customer coupons."), ("Who is the memo addressed to?", "Branch managers.", "Warehouse drivers.", "New interns.", "Outside suppliers."), ("What should branches using new software attach?", "A spreadsheet and a checklist.", "Only a handwritten note.", "A marketing poster.", "A fuel receipt.")]),
    ("P7_SET_07", "Questions 165-167 refer to the following online review.\n\nI recently stayed at the Pine Hill Lodge for two nights during a business trip. The room was quiet, the breakfast buffet had many options, and the staff helped me print meeting materials in the lobby business center. I would gladly stay there again.", [("What is being reviewed?", "A hotel stay.", "A restaurant delivery.", "A taxi service.", "A fitness class."), ("What did the writer appreciate about breakfast?", "There were many options.", "It was served until noon.", "It was included only on weekends.", "It was delivered to the room."), ("What did the staff help the writer do?", "Print meeting materials.", "Change a flight reservation.", "Wash clothing.", "Move luggage to another hotel.")]),
    ("P7_SET_08", "Questions 168-170 refer to the following notice and email.\n\n[Notice]\nThe Lakeside Community Center will close its pool from July 3 to July 10 for routine maintenance. Fitness classes in Studio A will continue as scheduled.\n\n[Email]\nFrom: Aaron\nTo: Maya\nI know you planned to swim next week, but the pool will be closed for maintenance. If you still want to exercise, I can join you for the Tuesday evening yoga class instead.", [("What facility will be closed?", "The pool.", "Studio A.", "The front desk.", "The parking lot."), ("What will continue as scheduled?", "Fitness classes in Studio A.", "Swimming lessons.", "Child-care services.", "Basketball practice."), ("What does Aaron suggest?", "Attending a yoga class instead.", "Waiting until August to exercise.", "Using a different community center.", "Requesting a refund immediately.")]),
    ("P7_SET_09", "Questions 171-173 refer to the following article and form.\n\n[Article]\nThe annual River Clean-Up Day will be held on September 14. Volunteers will gather at 8 a.m. in Riverside Park and will receive gloves, trash bags, and refreshments.\n\n[Form]\nVolunteer Name: ____\nPreferred Task: shoreline cleanup / registration table / refreshments\nT-shirt Size: S / M / L / XL", [("What event is described?", "River Clean-Up Day.", "A charity concert.", "A museum opening.", "A school sports festival."), ("What will volunteers receive?", "Gloves, trash bags, and refreshments.", "A transportation pass.", "A bicycle helmet.", "A hotel discount."), ("What information is requested on the form?", "A preferred task.", "A passport number.", "A meal receipt.", "A banking code.")]),
    ("P7_SET_10", "Questions 174-176 refer to the following web article and message.\n\n[Article]\nStarting this month, the Metro Library app allows users to renew borrowed books, reserve study rooms, and receive reminders before due dates.\n\n[Message]\nHi Jisoo, I used the library app to reserve a study room for Saturday morning. You should download it too because it also sends alerts before books are due.", [("What new service does the app provide?", "Study room reservations.", "Restaurant discounts.", "Language lessons.", "Parking validation."), ("When was the study room reserved for?", "Saturday morning.", "Friday evening.", "This afternoon.", "Next month."), ("Why does the writer recommend the app?", "It sends due-date reminders.", "It provides free textbooks.", "It has a map of coffee shops.", "It allows users to print for free.")]),
    ("P7_SET_11", "Questions 177-179 refer to the following flyer.\n\nJoin us for the Autumn Craft Fair at Maple Hall this Sunday from 11 a.m. to 5 p.m. Local artists will sell handmade jewelry, ceramics, and textile goods. Early visitors will receive a reusable shopping bag while supplies last.", [("What event is being promoted?", "A craft fair.", "A financial seminar.", "A job interview day.", "A warehouse sale."), ("What items will be sold?", "Handmade goods.", "Used office furniture.", "Imported electronics.", "Concert tickets."), ("What will early visitors receive?", "A reusable shopping bag.", "A free lunch.", "A train voucher.", "A pottery lesson.")]),
    ("P7_SET_12", "Questions 180-182 refer to the following letter.\n\nDear Subscribers,\nBeginning in August, Home Garden Magazine will publish an additional digital issue each month featuring seasonal planting guides and video interviews with gardening experts. Printed subscriptions will continue unchanged.", [("What change is being announced?", "An extra digital issue each month.", "A price increase for printed copies.", "A new office address.", "A shorter subscription period."), ("What will the digital issue include?", "Planting guides and video interviews.", "Free seeds and tools.", "Restaurant coupons.", "Travel reviews."), ("What will happen to printed subscriptions?", "They will continue unchanged.", "They will be canceled.", "They will become digital only.", "They will be mailed weekly.")]),
    ("P7_SET_13", "Questions 183-185 refer to the following email and schedule.\n\n[Email]\nPlease remember that our visiting speaker from Vancouver will arrive on Thursday evening. We need volunteers to greet her at the hotel and to prepare the seminar room before Friday's session.\n\n[Schedule]\nThursday 7:30 p.m. hotel welcome\nFriday 8:00 a.m. room setup\nFriday 10:00 a.m. seminar begins", [("Why is the email being sent?", "To request volunteers.", "To cancel the seminar.", "To collect donations.", "To reserve hotel rooms for staff."), ("When does the seminar begin?", "Friday at 10:00 a.m.", "Thursday at 7:30 p.m.", "Friday at 8:00 a.m.", "Saturday morning."), ("What happens on Thursday evening?", "The speaker is welcomed at the hotel.", "The seminar room is cleaned.", "The seminar begins.", "Volunteers attend training.")]),
    ("P7_SET_14", "Questions 186-188 refer to the following online posting.\n\nFor Sale: lightly used espresso machine, purchased last year for a cafe project. Includes metal frothing pitcher and instruction booklet. Pick-up is available near East Market Station, or local delivery can be arranged for an extra fee.", [("What item is for sale?", "An espresso machine.", "A train ticket.", "A tablet computer.", "A set of office shelves."), ("What is included with the item?", "A pitcher and booklet.", "A one-year warranty extension.", "Free coffee beans.", "A replacement filter only."), ("What delivery option is mentioned?", "Local delivery for an extra fee.", "International shipping at no charge.", "Delivery only by train.", "Pickup is not possible.")]),
    ("P7_SET_15", "Questions 189-191 refer to the following announcement and map.\n\n[Announcement]\nBeginning July 1, visitors to Green Valley Park must use the new west entrance while the south gate is repaired. Parking is available beside the visitor center.\n\n[Map Summary]\nWest entrance -> visitor center parking -> lake trail", [("Which entrance should visitors use?", "The west entrance.", "The south gate.", "The east service road.", "The staff driveway."), ("Why is the change being made?", "The south gate is being repaired.", "The parking lot is expanding.", "A festival is scheduled.", "The park is closing early."), ("Where is parking available?", "Beside the visitor center.", "Along the lake trail.", "At the south gate.", "Near the maintenance shed.")]),
    ("P7_SET_16", "Questions 192-194 refer to the following report and email.\n\n[Report]\nThe customer survey showed that delivery speed improved significantly after the company added two evening drivers in March. However, respondents still requested better package tracking updates.\n\n[Email]\nThanks for sharing the survey. Let's discuss the tracking issue in next week's operations meeting and see whether the app team can help.", [("What improved after March?", "Delivery speed.", "Advertising costs.", "Office attendance.", "Printer maintenance."), ("What did customers still want?", "Better tracking updates.", "Longer store hours.", "A free loyalty card.", "More evening drivers."), ("What does the writer suggest doing next?", "Discussing the issue at an operations meeting.", "Hiring more drivers immediately.", "Repeating the survey tomorrow.", "Closing the app team office.")]),
    ("P7_SET_17", "Questions 195-197 refer to the following brochure and memo.\n\n[Brochure]\nThe Seaside Business Hotel offers discounted weekday rates for conference attendees. Guests may use the business lounge, complimentary Wi-Fi, and airport shuttle service.\n\n[Memo]\nPlease book rooms at the Seaside Business Hotel for our conference speakers. The shuttle service will make airport arrivals easier, and the weekday discount will help us stay within budget.", [("Who receives discounted rates?", "Conference attendees.", "Weekend tourists only.", "Airport employees.", "Students."), ("What service is specifically mentioned in both texts?", "Airport shuttle service.", "Spa treatment.", "Valet parking.", "Laundry delivery."), ("Why does the memo writer prefer this hotel?", "It is convenient and cost-effective.", "It is the newest hotel in the city.", "It has the largest ballroom.", "It is nearest to the beach.")]),
    ("P7_SET_18", "Questions 198-200 refer to the following article and message board post.\n\n[Article]\nThe Hilltop Farmers' Market will relocate to Pine Square for the summer because construction is underway at its usual location. Vendors will continue to operate on Saturdays from 8 a.m. to 1 p.m.\n\n[Post]\nThanks for sharing the update. Pine Square is actually closer to my office, so I'll be able to stop by the market before work this Saturday.", [("Why is the market relocating?", "Construction is underway at the usual location.", "The vendors requested shorter hours.", "The city canceled Saturday events.", "The market is expanding internationally."), ("When will the market operate?", "On Saturdays from 8 a.m. to 1 p.m.", "Every weekday at noon.", "Only on Sunday evenings.", "On Fridays after work."), ("Why is the writer pleased about the move?", "The new location is closer to the office.", "Parking is now free for vendors.", "The market will open earlier on weekdays.", "The construction will end this week.")]),
]

for group_key, passage, qs in part7_sets:
    for order, (content, a, b, c, d) in enumerate(qs, 1):
        add_question(
            part=7,
            section="reading",
            group_key=group_key,
            question_order=order,
            instructions="Part 7: Read the text and answer the questions.",
            shared_content=passage,
            content=content,
            option_a=a,
            option_b=b,
            option_c=c,
            option_d=d,
            correct_answer="A",
            explanation="Find the answer that matches the information in the passage.",
        )


assert len(rows) == 200, len(rows)

columns = [
    "part",
    "section",
    "group_key",
    "question_order",
    "instructions",
    "shared_content",
    "shared_audio_url",
    "shared_image_url",
    "content",
    "option_a",
    "option_b",
    "option_c",
    "option_d",
    "correct_answer",
    "explanation",
    "audio_url",
    "image_url",
]

lines = [
    "-- Seed 1 de TOEIC full test 200 cau, dung cho cau truc 7 part.",
    "-- Script nay se xoa du lieu cau hoi cu va nap lai dung 200 cau theo phan bo TOEIC that.",
    "SET FOREIGN_KEY_CHECKS = 0;",
    "DELETE FROM test_attempt_answers;",
    "DELETE FROM user_bookmarks;",
    "DELETE FROM questions;",
    "ALTER TABLE questions AUTO_INCREMENT = 1;",
    "",
    "INSERT INTO questions (",
]

for index, column in enumerate(columns):
    lines.append(f"    {column}{',' if index < len(columns) - 1 else ''}")

lines.extend([")", "VALUES"])

for index, row in enumerate(rows):
    values = ", ".join(esc(row[column]) for column in columns)
    lines.append(f"    ({values}){',' if index < len(rows) - 1 else ';'}")

lines.extend(["", "SET FOREIGN_KEY_CHECKS = 1;"])

OUT.write_text("\n".join(lines), encoding="utf-8")
print(f"Wrote {OUT.name} with {len(rows)} questions.")
