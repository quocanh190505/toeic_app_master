-- Seed 1 de TOEIC full test 200 cau, dung cho cau truc 7 part.
-- Script nay se xoa du lieu cau hoi cu va nap lai dung 200 cau theo phan bo TOEIC that.
SET FOREIGN_KEY_CHECKS = 0;
DELETE FROM test_attempt_answers;
DELETE FROM user_bookmarks;
DELETE FROM questions;
ALTER TABLE questions AUTO_INCREMENT = 1;

INSERT INTO questions (
    part,
    section,
    group_key,
    question_order,
    instructions,
    shared_content,
    shared_audio_url,
    shared_image_url,
    content,
    option_a,
    option_b,
    option_c,
    option_d,
    correct_answer,
    explanation,
    audio_url,
    image_url
)
VALUES
    ('1', 'listening', NULL, '1', 'Part 1: Listen to the statements and choose the sentence that best describes the picture.', NULL, NULL, NULL, 'Look at the picture and choose the best description.', 'A photographer is adjusting a camera on a tripod.', 'Two customers are browsing in a bookstore.', 'A server is carrying drinks to a table.', 'A mechanic is checking a tire gauge.', 'A', 'The picture focuses on a photographer preparing a camera on a tripod.', NULL, NULL),
    ('1', 'listening', NULL, '1', 'Part 1: Listen to the statements and choose the sentence that best describes the picture.', NULL, NULL, NULL, 'Look at the picture and choose the best description.', 'Several employees are seated around a conference table.', 'A chef is placing bread in an oven.', 'A passenger is locking a suitcase.', 'A cyclist is crossing a narrow bridge.', 'A', 'The people are gathered around a conference table.', NULL, NULL),
    ('1', 'listening', NULL, '1', 'Part 1: Listen to the statements and choose the sentence that best describes the picture.', NULL, NULL, NULL, 'Look at the picture and choose the best description.', 'A woman is watering plants inside a greenhouse.', 'A cashier is scanning a customer card.', 'A child is painting a fence.', 'A waiter is folding napkins.', 'A', 'The woman is watering plants in a greenhouse setting.', NULL, NULL),
    ('1', 'listening', NULL, '1', 'Part 1: Listen to the statements and choose the sentence that best describes the picture.', NULL, NULL, NULL, 'Look at the picture and choose the best description.', 'Boxes are being loaded onto a delivery truck.', 'A pilot is speaking to passengers.', 'A clerk is hanging coats in a closet.', 'A group is watching a movie screen.', 'A', 'The scene shows boxes being loaded onto a truck.', NULL, NULL),
    ('1', 'listening', NULL, '1', 'Part 1: Listen to the statements and choose the sentence that best describes the picture.', NULL, NULL, NULL, 'Look at the picture and choose the best description.', 'A man is repairing a computer in an office.', 'A shopper is trying on a jacket.', 'A barista is grinding coffee beans.', 'A musician is tuning a violin.', 'A', 'The man is working on a computer in an office.', NULL, NULL),
    ('1', 'listening', NULL, '1', 'Part 1: Listen to the statements and choose the sentence that best describes the picture.', NULL, NULL, NULL, 'Look at the picture and choose the best description.', 'Some bicycles are parked beside a building.', 'A gardener is trimming a hedge.', 'A technician is replacing ceiling lights.', 'People are boarding a ferry.', 'A', 'The most accurate description is that bicycles are parked beside a building.', NULL, NULL),
    ('2', 'listening', NULL, '1', 'Part 2: Listen to the question or statement and choose the best response.', NULL, NULL, NULL, 'Where should the visitors wait?', 'In the reception area.', 'At half past two.', 'With the blue folders.', 'Because the manager is busy.', 'A', 'Choose the response that most naturally answers the question.', NULL, NULL),
    ('2', 'listening', NULL, '1', 'Part 2: Listen to the question or statement and choose the best response.', NULL, NULL, NULL, 'Who approved the budget revision?', 'The finance director did.', 'During the morning commute.', 'At the branch office.', 'A revised schedule.', 'A', 'Choose the response that most naturally answers the question.', NULL, NULL),
    ('2', 'listening', NULL, '1', 'Part 2: Listen to the question or statement and choose the best response.', NULL, NULL, NULL, 'Why is the printer offline?', 'It ran out of paper.', 'Next to the supply closet.', 'A color brochure.', 'For tomorrow''s event.', 'A', 'Choose the response that most naturally answers the question.', NULL, NULL),
    ('2', 'listening', NULL, '1', 'Part 2: Listen to the question or statement and choose the best response.', NULL, NULL, NULL, 'When will the shipment arrive?', 'Early Friday morning.', 'On the loading dock.', 'A delivery receipt.', 'Because of traffic.', 'A', 'Choose the response that most naturally answers the question.', NULL, NULL),
    ('2', 'listening', NULL, '1', 'Part 2: Listen to the question or statement and choose the best response.', NULL, NULL, NULL, 'How do I access the staff portal?', 'Use your employee ID and password.', 'It was updated last week.', 'From the IT department.', 'Near the front entrance.', 'A', 'Choose the response that most naturally answers the question.', NULL, NULL),
    ('2', 'listening', NULL, '1', 'Part 2: Listen to the question or statement and choose the best response.', NULL, NULL, NULL, 'Where did Ms. Gomez put the contract?', 'On your desk this morning.', 'For six more months.', 'With the legal team.', 'Because it needs a signature.', 'A', 'Choose the response that most naturally answers the question.', NULL, NULL),
    ('2', 'listening', NULL, '1', 'Part 2: Listen to the question or statement and choose the best response.', NULL, NULL, NULL, 'Why was the meeting postponed?', 'Several team members were traveling.', 'At the downtown office.', 'An updated sales chart.', 'For the new interns.', 'A', 'Choose the response that most naturally answers the question.', NULL, NULL),
    ('2', 'listening', NULL, '1', 'Part 2: Listen to the question or statement and choose the best response.', NULL, NULL, NULL, 'Who is giving the presentation today?', 'Mr. Harris from marketing.', 'In the main auditorium.', 'A slide deck about exports.', 'At three-thirty exactly.', 'A', 'Choose the response that most naturally answers the question.', NULL, NULL),
    ('2', 'listening', NULL, '1', 'Part 2: Listen to the question or statement and choose the best response.', NULL, NULL, NULL, 'When does the cafeteria close?', 'At seven in the evening.', 'Beside the copy room.', 'A bowl of soup, please.', 'Because the chef is away.', 'A', 'Choose the response that most naturally answers the question.', NULL, NULL),
    ('2', 'listening', NULL, '1', 'Part 2: Listen to the question or statement and choose the best response.', NULL, NULL, NULL, 'How often are expense reports reviewed?', 'Usually once a month.', 'By the elevator lobby.', 'An accounting software update.', 'After the trade fair.', 'A', 'Choose the response that most naturally answers the question.', NULL, NULL),
    ('2', 'listening', NULL, '1', 'Part 2: Listen to the question or statement and choose the best response.', NULL, NULL, NULL, 'Which department handles returns?', 'Customer service does.', 'On the third floor.', 'A larger storage cabinet.', 'By courier yesterday.', 'A', 'Choose the response that most naturally answers the question.', NULL, NULL),
    ('2', 'listening', NULL, '1', 'Part 2: Listen to the question or statement and choose the best response.', NULL, NULL, NULL, 'Why did the technician visit the warehouse?', 'To inspect the cooling system.', 'At the loading entrance.', 'A pair of safety gloves.', 'With the night supervisor.', 'A', 'Choose the response that most naturally answers the question.', NULL, NULL),
    ('2', 'listening', NULL, '1', 'Part 2: Listen to the question or statement and choose the best response.', NULL, NULL, NULL, 'Where can I find the training manual?', 'It is saved on the shared drive.', 'For the new schedule.', 'In about ten minutes.', 'By the accounting staff.', 'A', 'Choose the response that most naturally answers the question.', NULL, NULL),
    ('2', 'listening', NULL, '1', 'Part 2: Listen to the question or statement and choose the best response.', NULL, NULL, NULL, 'Who will meet the client at the airport?', 'Natalie will pick him up.', 'At the arrival gate.', 'A company brochure.', 'Because the flight was delayed.', 'A', 'Choose the response that most naturally answers the question.', NULL, NULL),
    ('2', 'listening', NULL, '1', 'Part 2: Listen to the question or statement and choose the best response.', NULL, NULL, NULL, 'How long will the audit take?', 'About three business days.', 'In the archive room.', 'A revised checklist.', 'With the external consultant.', 'A', 'Choose the response that most naturally answers the question.', NULL, NULL),
    ('2', 'listening', NULL, '1', 'Part 2: Listen to the question or statement and choose the best response.', NULL, NULL, NULL, 'When was the software patch installed?', 'Late last night.', 'On the office laptop.', 'A faster internet plan.', 'Before the annual dinner.', 'A', 'Choose the response that most naturally answers the question.', NULL, NULL),
    ('2', 'listening', NULL, '1', 'Part 2: Listen to the question or statement and choose the best response.', NULL, NULL, NULL, 'Why are the lights still on in Conference Room B?', 'The cleaning crew is still there.', 'By the glass entrance.', 'A stack of brochures.', 'At the end of the hallway.', 'A', 'Choose the response that most naturally answers the question.', NULL, NULL),
    ('2', 'listening', NULL, '1', 'Part 2: Listen to the question or statement and choose the best response.', NULL, NULL, NULL, 'Who can sign this purchase request?', 'The operations manager can.', 'At the front counter.', 'A packet of invoices.', 'Before the supplier arrives.', 'A', 'Choose the response that most naturally answers the question.', NULL, NULL),
    ('2', 'listening', NULL, '1', 'Part 2: Listen to the question or statement and choose the best response.', NULL, NULL, NULL, 'Where is the nearest parking garage?', 'Across from the bank.', 'At eleven-fifteen.', 'A silver sedan.', 'Because the lot is full.', 'A', 'Choose the response that most naturally answers the question.', NULL, NULL),
    ('2', 'listening', NULL, '1', 'Part 2: Listen to the question or statement and choose the best response.', NULL, NULL, NULL, 'How many copies should I print?', 'Please make ten copies.', 'Near the reception desk.', 'A color printer.', 'For the welcome packets.', 'A', 'Choose the response that most naturally answers the question.', NULL, NULL),
    ('2', 'listening', NULL, '1', 'Part 2: Listen to the question or statement and choose the best response.', NULL, NULL, NULL, 'Why did the courier call?', 'To confirm the delivery address.', 'At the security desk.', 'A signed receipt.', 'By express train.', 'A', 'Choose the response that most naturally answers the question.', NULL, NULL),
    ('2', 'listening', NULL, '1', 'Part 2: Listen to the question or statement and choose the best response.', NULL, NULL, NULL, 'Who is responsible for the new website design?', 'An outside agency is.', 'In the top drawer.', 'About two weeks ago.', 'A larger monitor.', 'A', 'Choose the response that most naturally answers the question.', NULL, NULL),
    ('2', 'listening', NULL, '1', 'Part 2: Listen to the question or statement and choose the best response.', NULL, NULL, NULL, 'When are the interns starting?', 'They begin next Monday.', 'At the side entrance.', 'A welcome speech.', 'Because orientation was canceled.', 'A', 'Choose the response that most naturally answers the question.', NULL, NULL),
    ('2', 'listening', NULL, '1', 'Part 2: Listen to the question or statement and choose the best response.', NULL, NULL, NULL, 'How was the conference in Busan?', 'It was very productive.', 'At the harbor district.', 'A printed itinerary.', 'For the regional managers.', 'A', 'Choose the response that most naturally answers the question.', NULL, NULL),
    ('2', 'listening', NULL, '1', 'Part 2: Listen to the question or statement and choose the best response.', NULL, NULL, NULL, 'Where should these sample products be stored?', 'Put them in the display cabinet.', 'At the quarterly review.', 'A red shipping label.', 'Because the shelf is broken.', 'A', 'Choose the response that most naturally answers the question.', NULL, NULL),
    ('3', 'listening', 'P3_SET_01', '1', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 32-34 refer to the following conversation.

Woman: Daniel, have the brochures for the Osaka trade show arrived yet?
Man: Yes, they were delivered this morning, but the display banners are still missing.
Woman: Then please call the printer and ask whether they can bring the banners before noon.', NULL, NULL, 'What are the speakers mainly discussing?', 'Materials for a trade show.', 'A delayed flight itinerary.', 'A hotel reservation.', 'A hiring decision.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_01', '2', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 32-34 refer to the following conversation.

Woman: Daniel, have the brochures for the Osaka trade show arrived yet?
Man: Yes, they were delivered this morning, but the display banners are still missing.
Woman: Then please call the printer and ask whether they can bring the banners before noon.', NULL, NULL, 'What has already arrived?', 'The brochures.', 'The display banners.', 'The catering order.', 'The name badges.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_01', '3', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 32-34 refer to the following conversation.

Woman: Daniel, have the brochures for the Osaka trade show arrived yet?
Man: Yes, they were delivered this morning, but the display banners are still missing.
Woman: Then please call the printer and ask whether they can bring the banners before noon.', NULL, NULL, 'What does the woman ask the man to do?', 'Call the printer.', 'Book a taxi.', 'Edit the brochure text.', 'Meet a client at noon.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_02', '1', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 35-37 refer to the following conversation.

Man: Hi, Elena. I reviewed your draft of the monthly report.
Woman: Great. Is there anything else I should add before I send it to the director?
Man: Please include the updated sales chart on page four and then email the final version to me.', NULL, NULL, 'What are the speakers talking about?', 'A monthly report.', 'An office renovation.', 'A training session.', 'A delivery route.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_02', '2', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 35-37 refer to the following conversation.

Man: Hi, Elena. I reviewed your draft of the monthly report.
Woman: Great. Is there anything else I should add before I send it to the director?
Man: Please include the updated sales chart on page four and then email the final version to me.', NULL, NULL, 'What should the woman add?', 'An updated sales chart.', 'A conference schedule.', 'A budget request.', 'A customer survey.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_02', '3', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 35-37 refer to the following conversation.

Man: Hi, Elena. I reviewed your draft of the monthly report.
Woman: Great. Is there anything else I should add before I send it to the director?
Man: Please include the updated sales chart on page four and then email the final version to me.', NULL, NULL, 'What will the woman probably do next?', 'Send the final version by email.', 'Visit page four of a website.', 'Call the director directly.', 'Print new business cards.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_03', '1', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 38-40 refer to the following conversation.

Woman: The coffee machine on the third floor is out of order again.
Man: I noticed that this morning. The maintenance company said a technician can come tomorrow.
Woman: Okay, I''ll post a notice in the break room so everyone knows to use the first-floor kitchen today.', NULL, NULL, 'What problem do the speakers mention?', 'A broken coffee machine.', 'A delayed lunch order.', 'A missing key card.', 'A canceled meeting room booking.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_03', '2', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 38-40 refer to the following conversation.

Woman: The coffee machine on the third floor is out of order again.
Man: I noticed that this morning. The maintenance company said a technician can come tomorrow.
Woman: Okay, I''ll post a notice in the break room so everyone knows to use the first-floor kitchen today.', NULL, NULL, 'When can the technician come?', 'Tomorrow.', 'This afternoon.', 'Next week.', 'In an hour.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_03', '3', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 38-40 refer to the following conversation.

Woman: The coffee machine on the third floor is out of order again.
Man: I noticed that this morning. The maintenance company said a technician can come tomorrow.
Woman: Okay, I''ll post a notice in the break room so everyone knows to use the first-floor kitchen today.', NULL, NULL, 'What will the woman do?', 'Post a notice.', 'Call the security desk.', 'Order bottled water.', 'Move the machine downstairs.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_04', '1', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 41-43 refer to the following conversation.

Man: Have you finished checking the guest list for Friday''s banquet?
Woman: Almost. Two company names were misspelled, so I''m correcting them now.
Man: Good. Once you''re done, please forward the list to the catering manager.', NULL, NULL, 'What event are the speakers preparing for?', 'A banquet.', 'A product launch video.', 'A warehouse tour.', 'A job fair.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_04', '2', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 41-43 refer to the following conversation.

Man: Have you finished checking the guest list for Friday''s banquet?
Woman: Almost. Two company names were misspelled, so I''m correcting them now.
Man: Good. Once you''re done, please forward the list to the catering manager.', NULL, NULL, 'What is the woman doing now?', 'Correcting misspelled names.', 'Calling the catering manager.', 'Booking a conference hall.', 'Designing invitation cards.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_04', '3', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 41-43 refer to the following conversation.

Man: Have you finished checking the guest list for Friday''s banquet?
Woman: Almost. Two company names were misspelled, so I''m correcting them now.
Man: Good. Once you''re done, please forward the list to the catering manager.', NULL, NULL, 'What should happen after the corrections are made?', 'The list should be forwarded to the catering manager.', 'The banquet should be postponed.', 'The menu should be printed.', 'The guests should be called individually.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_05', '1', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 44-46 refer to the following conversation.

Woman: I''m looking for the conference badge printer.
Man: It''s in the registration area near the main entrance.
Woman: Thanks. I need to print badges for three late attendees before the keynote starts.', NULL, NULL, 'Where does the conversation most likely take place?', 'At a conference venue.', 'At a post office.', 'At a train station.', 'At a restaurant kitchen.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_05', '2', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 44-46 refer to the following conversation.

Woman: I''m looking for the conference badge printer.
Man: It''s in the registration area near the main entrance.
Woman: Thanks. I need to print badges for three late attendees before the keynote starts.', NULL, NULL, 'Where is the badge printer?', 'Near the main entrance.', 'Inside the storage room.', 'Next to the keynote stage.', 'On the second floor.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_05', '3', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 44-46 refer to the following conversation.

Woman: I''m looking for the conference badge printer.
Man: It''s in the registration area near the main entrance.
Woman: Thanks. I need to print badges for three late attendees before the keynote starts.', NULL, NULL, 'Why does the woman need the printer?', 'To print badges for late attendees.', 'To prepare meal vouchers.', 'To make copies of a contract.', 'To replace a damaged poster.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_06', '1', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 47-49 refer to the following conversation.

Man: Did the supplier send the replacement parts?
Woman: Yes, but only half of the order was included.
Man: Then I''ll call them and ask for the remaining parts to be sent by express delivery.', NULL, NULL, 'What did the supplier send?', 'Replacement parts.', 'Employee uniforms.', 'A payment receipt.', 'Promotional leaflets.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_06', '2', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 47-49 refer to the following conversation.

Man: Did the supplier send the replacement parts?
Woman: Yes, but only half of the order was included.
Man: Then I''ll call them and ask for the remaining parts to be sent by express delivery.', NULL, NULL, 'What problem is mentioned?', 'Only half of the order arrived.', 'The shipment was sent to the wrong city.', 'The boxes were empty.', 'The price was too high.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_06', '3', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 47-49 refer to the following conversation.

Man: Did the supplier send the replacement parts?
Woman: Yes, but only half of the order was included.
Man: Then I''ll call them and ask for the remaining parts to be sent by express delivery.', NULL, NULL, 'What will the man do?', 'Request express delivery for the rest.', 'Cancel the entire order.', 'Pick up the parts himself.', 'Return the delivered items.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_07', '1', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 50-52 refer to the following conversation.

Woman: Are you still planning to attend the training session this afternoon?
Man: Yes, but I may be a few minutes late because I have to meet a client first.
Woman: No problem. I''ll save you a seat near the front.', NULL, NULL, 'What are the speakers discussing?', 'A training session.', 'A hotel checkout time.', 'A sales target.', 'A new software license.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_07', '2', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 50-52 refer to the following conversation.

Woman: Are you still planning to attend the training session this afternoon?
Man: Yes, but I may be a few minutes late because I have to meet a client first.
Woman: No problem. I''ll save you a seat near the front.', NULL, NULL, 'Why might the man be late?', 'He has to meet a client.', 'His train was canceled.', 'He needs to print materials.', 'He is waiting for a parcel.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_07', '3', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 50-52 refer to the following conversation.

Woman: Are you still planning to attend the training session this afternoon?
Man: Yes, but I may be a few minutes late because I have to meet a client first.
Woman: No problem. I''ll save you a seat near the front.', NULL, NULL, 'What does the woman offer to do?', 'Save a seat.', 'Reschedule the session.', 'Send the client a message.', 'Bring refreshments.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_08', '1', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 53-55 refer to the following conversation.

Man: I''m having trouble logging into the inventory system.
Woman: Did you reset your password after the security update?
Man: Not yet. I''ll do that now and try again before I contact IT.', NULL, NULL, 'What problem does the man have?', 'He cannot log into a system.', 'He lost a package.', 'He missed a deadline.', 'He forgot a meeting location.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_08', '2', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 53-55 refer to the following conversation.

Man: I''m having trouble logging into the inventory system.
Woman: Did you reset your password after the security update?
Man: Not yet. I''ll do that now and try again before I contact IT.', NULL, NULL, 'What does the woman mention?', 'A security update.', 'A delayed audit.', 'A new office layout.', 'A client complaint.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_08', '3', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 53-55 refer to the following conversation.

Man: I''m having trouble logging into the inventory system.
Woman: Did you reset your password after the security update?
Man: Not yet. I''ll do that now and try again before I contact IT.', NULL, NULL, 'What will the man do first?', 'Reset his password.', 'Call the IT manager.', 'Replace his laptop.', 'Update the inventory count.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_09', '1', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 56-58 refer to the following conversation.

Woman: The design team wants feedback on the new package label.
Man: I like the color scheme, but the product name should be larger.
Woman: I agree. I''ll send that suggestion before the review meeting starts.', NULL, NULL, 'What are the speakers giving feedback on?', 'A package label.', 'A parking plan.', 'A travel reimbursement form.', 'A customer invoice.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_09', '2', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 56-58 refer to the following conversation.

Woman: The design team wants feedback on the new package label.
Man: I like the color scheme, but the product name should be larger.
Woman: I agree. I''ll send that suggestion before the review meeting starts.', NULL, NULL, 'What does the man suggest changing?', 'Make the product name larger.', 'Use a different shipping company.', 'Add a second barcode.', 'Lower the price.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_09', '3', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 56-58 refer to the following conversation.

Woman: The design team wants feedback on the new package label.
Man: I like the color scheme, but the product name should be larger.
Woman: I agree. I''ll send that suggestion before the review meeting starts.', NULL, NULL, 'What will the woman do?', 'Send the suggestion before the review meeting.', 'Meet the design team tomorrow.', 'Print the labels immediately.', 'Cancel the review meeting.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_10', '1', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 59-61 refer to the following conversation.

Man: We need one more volunteer for the museum fundraising event.
Woman: I can help at the registration desk from noon until three.
Man: Perfect. I''ll add your name to the schedule and email you the instructions.', NULL, NULL, 'What event are the speakers discussing?', 'A fundraising event.', 'A warehouse inspection.', 'A lecture series.', 'A product recall.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_10', '2', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 59-61 refer to the following conversation.

Man: We need one more volunteer for the museum fundraising event.
Woman: I can help at the registration desk from noon until three.
Man: Perfect. I''ll add your name to the schedule and email you the instructions.', NULL, NULL, 'What will the woman do?', 'Work at the registration desk.', 'Design the event poster.', 'Collect parking fees.', 'Deliver museum exhibits.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_10', '3', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 59-61 refer to the following conversation.

Man: We need one more volunteer for the museum fundraising event.
Woman: I can help at the registration desk from noon until three.
Man: Perfect. I''ll add your name to the schedule and email you the instructions.', NULL, NULL, 'What will the man send by email?', 'Instructions.', 'A donation receipt.', 'A map of the museum.', 'A revised budget.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_11', '1', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 62-64 refer to the following conversation.

Woman: Have you seen the prototype for the folding chair?
Man: Yes, and the engineering team wants to test a lighter material.
Woman: That should reduce shipping costs, so let''s mention it in tomorrow''s planning meeting.', NULL, NULL, 'What product do the speakers mention?', 'A folding chair.', 'A tablet computer.', 'A coffee grinder.', 'A storage cabinet.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_11', '2', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 62-64 refer to the following conversation.

Woman: Have you seen the prototype for the folding chair?
Man: Yes, and the engineering team wants to test a lighter material.
Woman: That should reduce shipping costs, so let''s mention it in tomorrow''s planning meeting.', NULL, NULL, 'What does the engineering team want to test?', 'A lighter material.', 'A new advertising slogan.', 'A larger warehouse.', 'A lower retail price.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_11', '3', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 62-64 refer to the following conversation.

Woman: Have you seen the prototype for the folding chair?
Man: Yes, and the engineering team wants to test a lighter material.
Woman: That should reduce shipping costs, so let''s mention it in tomorrow''s planning meeting.', NULL, NULL, 'Why does the woman support the idea?', 'It should reduce shipping costs.', 'It will shorten the meeting.', 'It improves employee morale.', 'It requires less training.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_12', '1', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 65-67 refer to the following conversation.

Man: Did you reserve the van for tomorrow''s site visit?
Woman: Yes, but we need to return it by 5 p.m. because another team booked it for the evening.
Man: That''s fine. We should be back well before then.', NULL, NULL, 'Why do the speakers need a van?', 'For a site visit.', 'For an office move.', 'For a client banquet.', 'For a museum tour.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_12', '2', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 65-67 refer to the following conversation.

Man: Did you reserve the van for tomorrow''s site visit?
Woman: Yes, but we need to return it by 5 p.m. because another team booked it for the evening.
Man: That''s fine. We should be back well before then.', NULL, NULL, 'What limitation does the woman mention?', 'The van must be returned by 5 p.m.', 'The van can only hold four people.', 'The driver is unavailable.', 'The fuel tank is empty.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_12', '3', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 65-67 refer to the following conversation.

Man: Did you reserve the van for tomorrow''s site visit?
Woman: Yes, but we need to return it by 5 p.m. because another team booked it for the evening.
Man: That''s fine. We should be back well before then.', NULL, NULL, 'What does the man say about the schedule?', 'They should return before 5 p.m.', 'They will leave later in the day.', 'They need a second van.', 'They will cancel the visit.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_13', '1', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 68-70 refer to the following conversation.

Woman: The accountant asked for your signed travel claim form.
Man: I thought I submitted it yesterday.
Woman: The form was missing your signature, so I left it on your chair for you to complete this morning.', NULL, NULL, 'What document is being discussed?', 'A travel claim form.', 'A delivery invoice.', 'A performance review.', 'A parking permit.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_13', '2', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 68-70 refer to the following conversation.

Woman: The accountant asked for your signed travel claim form.
Man: I thought I submitted it yesterday.
Woman: The form was missing your signature, so I left it on your chair for you to complete this morning.', NULL, NULL, 'What was missing from the form?', 'A signature.', 'A mailing address.', 'A tax code.', 'A payment date.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('3', 'listening', 'P3_SET_13', '3', 'Part 3: Listen to the conversation and answer the questions.', 'Questions 68-70 refer to the following conversation.

Woman: The accountant asked for your signed travel claim form.
Man: I thought I submitted it yesterday.
Woman: The form was missing your signature, so I left it on your chair for you to complete this morning.', NULL, NULL, 'Where did the woman leave the form?', 'On the man''s chair.', 'At the front desk.', 'In the accountant''s office.', 'Inside the meeting room.', 'A', 'Use the details in the conversation to choose the best answer.', NULL, NULL),
    ('4', 'listening', 'P4_SET_01', '1', 'Part 4: Listen to the talk and answer the questions.', 'Questions 71-73 refer to the following talk.

Good morning, passengers. Train 204 to Daejeon will depart from platform 6 instead of platform 4 because of track maintenance. The departure time remains 8:15, and station staff are available if you need directions.', NULL, NULL, 'What is the announcement mainly about?', 'A platform change.', 'A ticket discount.', 'A weather delay.', 'A lost item report.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_01', '2', 'Part 4: Listen to the talk and answer the questions.', 'Questions 71-73 refer to the following talk.

Good morning, passengers. Train 204 to Daejeon will depart from platform 6 instead of platform 4 because of track maintenance. The departure time remains 8:15, and station staff are available if you need directions.', NULL, NULL, 'Why was the platform changed?', 'Because of track maintenance.', 'Because the train arrived late.', 'Because the station is crowded.', 'Because the conductor is absent.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_01', '3', 'Part 4: Listen to the talk and answer the questions.', 'Questions 71-73 refer to the following talk.

Good morning, passengers. Train 204 to Daejeon will depart from platform 6 instead of platform 4 because of track maintenance. The departure time remains 8:15, and station staff are available if you need directions.', NULL, NULL, 'What time will the train depart?', 'At 8:15.', 'At 6:00.', 'At 4:20.', 'At 8:50.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_02', '1', 'Part 4: Listen to the talk and answer the questions.', 'Questions 74-76 refer to the following announcement.

This is a reminder that the downtown fitness center will close at 6 p.m. today for equipment cleaning. Members who normally attend evening classes may use the Riverside branch at no extra charge.', NULL, NULL, 'What business is making the announcement?', 'A fitness center.', 'A bank.', 'A bookstore.', 'A shipping company.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_02', '2', 'Part 4: Listen to the talk and answer the questions.', 'Questions 74-76 refer to the following announcement.

This is a reminder that the downtown fitness center will close at 6 p.m. today for equipment cleaning. Members who normally attend evening classes may use the Riverside branch at no extra charge.', NULL, NULL, 'Why will it close early?', 'For equipment cleaning.', 'For a staff party.', 'For inventory counting.', 'For a power outage.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_02', '3', 'Part 4: Listen to the talk and answer the questions.', 'Questions 74-76 refer to the following announcement.

This is a reminder that the downtown fitness center will close at 6 p.m. today for equipment cleaning. Members who normally attend evening classes may use the Riverside branch at no extra charge.', NULL, NULL, 'What can members do?', 'Use another branch.', 'Receive a refund.', 'Enroll in free training.', 'Park behind the building.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_03', '1', 'Part 4: Listen to the talk and answer the questions.', 'Questions 77-79 refer to the following recorded message.

Hello, this is the City Dental Clinic calling to remind you of your appointment with Dr. Han on Thursday at 10 a.m. If you need to change your appointment time, please call our office before 5 p.m. on Wednesday.', NULL, NULL, 'Who is the message for?', 'A patient.', 'A supplier.', 'A building manager.', 'A delivery driver.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_03', '2', 'Part 4: Listen to the talk and answer the questions.', 'Questions 77-79 refer to the following recorded message.

Hello, this is the City Dental Clinic calling to remind you of your appointment with Dr. Han on Thursday at 10 a.m. If you need to change your appointment time, please call our office before 5 p.m. on Wednesday.', NULL, NULL, 'When is the appointment?', 'Thursday at 10 a.m.', 'Wednesday at 5 p.m.', 'Thursday at 5 p.m.', 'Friday at 10 a.m.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_03', '3', 'Part 4: Listen to the talk and answer the questions.', 'Questions 77-79 refer to the following recorded message.

Hello, this is the City Dental Clinic calling to remind you of your appointment with Dr. Han on Thursday at 10 a.m. If you need to change your appointment time, please call our office before 5 p.m. on Wednesday.', NULL, NULL, 'What should the listener do to change the appointment?', 'Call before 5 p.m. on Wednesday.', 'Reply by email.', 'Visit the clinic in person.', 'Call after the appointment.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_04', '1', 'Part 4: Listen to the talk and answer the questions.', 'Questions 80-82 refer to the following excerpt from a talk.

As part of our orientation program, all new employees must complete safety training during their first week. The training room is on the second floor beside Human Resources, and the session begins at 9:30 each morning.', NULL, NULL, 'Who is the talk intended for?', 'New employees.', 'Building inspectors.', 'Visiting clients.', 'Security guards only.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_04', '2', 'Part 4: Listen to the talk and answer the questions.', 'Questions 80-82 refer to the following excerpt from a talk.

As part of our orientation program, all new employees must complete safety training during their first week. The training room is on the second floor beside Human Resources, and the session begins at 9:30 each morning.', NULL, NULL, 'Where is the training room?', 'Beside Human Resources.', 'On the ground floor.', 'Near the cafeteria.', 'Across from the parking garage.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_04', '3', 'Part 4: Listen to the talk and answer the questions.', 'Questions 80-82 refer to the following excerpt from a talk.

As part of our orientation program, all new employees must complete safety training during their first week. The training room is on the second floor beside Human Resources, and the session begins at 9:30 each morning.', NULL, NULL, 'When does the session begin?', 'At 9:30 each morning.', 'At 8:00 each morning.', 'Every Monday at noon.', 'On the first Friday of the month.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_05', '1', 'Part 4: Listen to the talk and answer the questions.', 'Questions 83-85 refer to the following advertisement.

Looking for a quick lunch near Central Station? Visit Green Bowl Cafe for fresh salads, sandwiches, and soup. This week only, customers who show a train ticket can receive a free drink with any meal purchase.', NULL, NULL, 'What is being advertised?', 'A cafe.', 'A travel agency.', 'A supermarket.', 'A repair shop.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_05', '2', 'Part 4: Listen to the talk and answer the questions.', 'Questions 83-85 refer to the following advertisement.

Looking for a quick lunch near Central Station? Visit Green Bowl Cafe for fresh salads, sandwiches, and soup. This week only, customers who show a train ticket can receive a free drink with any meal purchase.', NULL, NULL, 'Where is the cafe located?', 'Near Central Station.', 'Inside a bookstore.', 'At the city airport.', 'Across from the museum.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_05', '3', 'Part 4: Listen to the talk and answer the questions.', 'Questions 83-85 refer to the following advertisement.

Looking for a quick lunch near Central Station? Visit Green Bowl Cafe for fresh salads, sandwiches, and soup. This week only, customers who show a train ticket can receive a free drink with any meal purchase.', NULL, NULL, 'What special offer is mentioned?', 'A free drink with a meal purchase.', 'Half-price train tickets.', 'Free parking for a month.', 'A discount on salads only.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_06', '1', 'Part 4: Listen to the talk and answer the questions.', 'Questions 86-88 refer to the following weather report.

The weather for the east coast will remain sunny through most of the afternoon, but strong winds are expected after 6 p.m. Small fishing boats are advised to return to shore before the evening weather changes.', NULL, NULL, 'What is the report mainly about?', 'Weather conditions.', 'A harbor expansion.', 'A fishing competition.', 'A delayed ferry route.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_06', '2', 'Part 4: Listen to the talk and answer the questions.', 'Questions 86-88 refer to the following weather report.

The weather for the east coast will remain sunny through most of the afternoon, but strong winds are expected after 6 p.m. Small fishing boats are advised to return to shore before the evening weather changes.', NULL, NULL, 'When are strong winds expected?', 'After 6 p.m.', 'Before noon.', 'At sunrise.', 'Tomorrow morning.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_06', '3', 'Part 4: Listen to the talk and answer the questions.', 'Questions 86-88 refer to the following weather report.

The weather for the east coast will remain sunny through most of the afternoon, but strong winds are expected after 6 p.m. Small fishing boats are advised to return to shore before the evening weather changes.', NULL, NULL, 'Who is advised to return early?', 'Small fishing boats.', 'Train passengers.', 'Delivery trucks.', 'Museum visitors.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_07', '1', 'Part 4: Listen to the talk and answer the questions.', 'Questions 89-91 refer to the following voicemail.

Hi, Karen. This is Paul from Bright Print. Your order of 2,000 catalogues is ready for pickup. We are open until 7 tonight, but if that is inconvenient, we can deliver the boxes to your office tomorrow morning.', NULL, NULL, 'Why is Paul calling?', 'To say an order is ready.', 'To request a design file.', 'To cancel a contract.', 'To confirm a payment error.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_07', '2', 'Part 4: Listen to the talk and answer the questions.', 'Questions 89-91 refer to the following voicemail.

Hi, Karen. This is Paul from Bright Print. Your order of 2,000 catalogues is ready for pickup. We are open until 7 tonight, but if that is inconvenient, we can deliver the boxes to your office tomorrow morning.', NULL, NULL, 'What business does Paul work for?', 'A printing company.', 'A law office.', 'A travel service.', 'A furniture store.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_07', '3', 'Part 4: Listen to the talk and answer the questions.', 'Questions 89-91 refer to the following voicemail.

Hi, Karen. This is Paul from Bright Print. Your order of 2,000 catalogues is ready for pickup. We are open until 7 tonight, but if that is inconvenient, we can deliver the boxes to your office tomorrow morning.', NULL, NULL, 'What alternative does Paul offer?', 'Delivery tomorrow morning.', 'A refund this afternoon.', 'A larger order discount.', 'Pickup at a warehouse.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_08', '1', 'Part 4: Listen to the talk and answer the questions.', 'Questions 92-94 refer to the following announcement.

The museum''s modern art gallery will reopen this Saturday after a two-week renovation. To celebrate, guided tours will be offered every hour between 10 a.m. and 3 p.m., and members may bring one guest free of charge.', NULL, NULL, 'What place is being discussed?', 'A museum gallery.', 'A concert hall.', 'A library archive.', 'A sports arena.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_08', '2', 'Part 4: Listen to the talk and answer the questions.', 'Questions 92-94 refer to the following announcement.

The museum''s modern art gallery will reopen this Saturday after a two-week renovation. To celebrate, guided tours will be offered every hour between 10 a.m. and 3 p.m., and members may bring one guest free of charge.', NULL, NULL, 'Why had it been closed?', 'For renovation.', 'For inventory checks.', 'For staff training.', 'For a private event.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_08', '3', 'Part 4: Listen to the talk and answer the questions.', 'Questions 92-94 refer to the following announcement.

The museum''s modern art gallery will reopen this Saturday after a two-week renovation. To celebrate, guided tours will be offered every hour between 10 a.m. and 3 p.m., and members may bring one guest free of charge.', NULL, NULL, 'What benefit do members receive?', 'They may bring one guest free.', 'They receive a free lunch.', 'They can attend a private concert.', 'They may park without charge.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_09', '1', 'Part 4: Listen to the talk and answer the questions.', 'Questions 95-97 refer to the following radio report.

City officials announced that Oak Street will be closed to traffic this weekend while workers replace old water pipes. Drivers should follow the posted detour signs and allow extra travel time when heading downtown.', NULL, NULL, 'What will happen on Oak Street?', 'It will be closed to traffic.', 'A new bus route will open.', 'Parking fees will increase.', 'A food festival will be held.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_09', '2', 'Part 4: Listen to the talk and answer the questions.', 'Questions 95-97 refer to the following radio report.

City officials announced that Oak Street will be closed to traffic this weekend while workers replace old water pipes. Drivers should follow the posted detour signs and allow extra travel time when heading downtown.', NULL, NULL, 'Why is the street being closed?', 'Workers are replacing water pipes.', 'A parade is scheduled.', 'A building is being painted.', 'The road surface is icy.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_09', '3', 'Part 4: Listen to the talk and answer the questions.', 'Questions 95-97 refer to the following radio report.

City officials announced that Oak Street will be closed to traffic this weekend while workers replace old water pipes. Drivers should follow the posted detour signs and allow extra travel time when heading downtown.', NULL, NULL, 'What are drivers advised to do?', 'Follow detour signs.', 'Travel only at night.', 'Use public parking garages.', 'Avoid carrying heavy items.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_10', '1', 'Part 4: Listen to the talk and answer the questions.', 'Questions 98-100 refer to the following telephone message.

Hello, this is an automated call from SkyView Hotel. We are contacting guests arriving this evening to let them know that road construction near the main entrance may cause delays. Valet staff will be stationed at the east gate to assist with luggage.', NULL, NULL, 'Who is sending the message?', 'A hotel.', 'A delivery service.', 'An airline.', 'A bank.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_10', '2', 'Part 4: Listen to the talk and answer the questions.', 'Questions 98-100 refer to the following telephone message.

Hello, this is an automated call from SkyView Hotel. We are contacting guests arriving this evening to let them know that road construction near the main entrance may cause delays. Valet staff will be stationed at the east gate to assist with luggage.', NULL, NULL, 'What may cause delays?', 'Road construction.', 'Heavy rain.', 'A power failure.', 'A ticket inspection.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('4', 'listening', 'P4_SET_10', '3', 'Part 4: Listen to the talk and answer the questions.', 'Questions 98-100 refer to the following telephone message.

Hello, this is an automated call from SkyView Hotel. We are contacting guests arriving this evening to let them know that road construction near the main entrance may cause delays. Valet staff will be stationed at the east gate to assist with luggage.', NULL, NULL, 'Where will staff help guests?', 'At the east gate.', 'In the parking basement.', 'At the front desk only.', 'Near the restaurant entrance.', 'A', 'Choose the answer supported by the short talk.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'Ms. Lopez is responsible ____ updating the client database each week.', 'for', 'to', 'with', 'by', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'The new marketing assistant will begin work ____ Monday morning.', 'on', 'during', 'until', 'among', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'Please submit your travel receipts ____ the end of the month.', 'by', 'among', 'into', 'across', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'The conference room is unavailable today, so the meeting has been ____.', 'rescheduled', 'reschedule', 'rescheduling', 'reschedules', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'Customers are asked to keep their receipts ____ they need to exchange an item.', 'in case', 'such as', 'even though', 'as if', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'The finance team reviewed the proposal carefully before ____ it.', 'approving', 'approve', 'approved', 'approves', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'Because the elevator is under repair, employees should use the stairs ____.', 'instead', 'already', 'still', 'only', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'The manager requested a copy of the contract ____ signed by both companies.', 'that was', 'what is', 'who were', 'where being', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'Our supplier offered a discount because we ordered a ____ quantity of paper.', 'large', 'largely', 'larger', 'largestly', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'If you have any questions about the software, please contact the IT help desk ____.', 'directly', 'direct', 'direction', 'directness', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'The museum will remain open late ____ the summer festival.', 'during', 'between', 'among', 'beneath', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'All visitors must wear identification badges while they are ____ the factory.', 'inside', 'along', 'onto', 'beside', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'The warranty covers parts and labor ____ one full year after purchase.', 'for', 'since', 'throughout of', 'toward', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'Mr. Chen asked whether the final report had been ____ to the board yet.', 'sent', 'send', 'sending', 'sends', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'The restaurant became popular quickly because of its excellent service and ____ location.', 'convenient', 'convenience', 'conveniently', 'convening', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'Please place completed forms in the tray ____ the copy machine.', 'beside', 'between', 'towarding', 'through', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'The equipment manual is written clearly so that new employees can follow it ____.', 'easily', 'easy', 'easier', 'ease', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'The director was pleased ____ the sales team exceeded its quarterly goal.', 'that', 'what', 'whether of', 'than', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'Any employee who works overtime must receive prior ____ from a supervisor.', 'approval', 'approve', 'approved', 'approving', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'The shipment was delayed ____ severe weather near the port.', 'because of', 'in spite', 'as soon', 'instead of', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'The guide recommended that we ____ the museum before lunch to avoid the crowds.', 'visit', 'visited', 'visiting', 'visitor', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'The seminar attracted managers from Seoul, Busan, and several ____ cities.', 'other', 'another', 'others', 'the other one', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'After reviewing the budget, the committee decided to postpone the project ____.', 'temporarily', 'temporary', 'tempers', 'temporariness', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'Employees are reminded not to share passwords ____ anyone outside the company.', 'with', 'from', 'under', 'about', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'The advertising campaign was successful ____ it targeted young professionals.', 'because', 'unless', 'despite', 'whereas of', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'Please note that the cafeteria accepts credit cards but not personal ____.', 'checks', 'checking', 'checker', 'checked', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'The maintenance crew will inspect the air-conditioning units ____ the weekend.', 'over', 'since', 'among', 'beneath', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'Our branch office has hired two consultants who specialize in tax ____.', 'law', 'lawful', 'lawsuit', 'legally', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'The customer service team responded so ____ that the complaint was resolved in one day.', 'quickly', 'quick', 'quicker', 'quickness', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('5', 'reading', NULL, '1', 'Part 5: Choose the word or phrase that best completes the sentence.', NULL, NULL, NULL, 'The factory will expand production next year if demand continues to ____.', 'increase', 'increased', 'increasingly', 'increaser', 'A', 'Select the option that is grammatically and logically correct.', NULL, NULL),
    ('6', 'reading', 'P6_SET_01', '1', 'Part 6: Read the text and choose the best answer for each blank.', 'Questions 131-132 refer to the following text.

To: All Staff
Subject: Lobby renovation

Beginning next Tuesday, the main lobby will be partially closed while new flooring is installed. Employees should enter through the east doors and allow extra time in the morning. We expect the work to be completed by Friday evening, and the lobby will reopen on Monday.', NULL, NULL, 'Select the best word for Blank 1: Beginning next Tuesday, the main lobby will be partially closed while new flooring is ____.', 'installed', 'install', 'installing', 'installs', 'A', 'Use context and grammar to complete the text.', NULL, NULL),
    ('6', 'reading', 'P6_SET_01', '2', 'Part 6: Read the text and choose the best answer for each blank.', 'Questions 131-132 refer to the following text.

To: All Staff
Subject: Lobby renovation

Beginning next Tuesday, the main lobby will be partially closed while new flooring is installed. Employees should enter through the east doors and allow extra time in the morning. We expect the work to be completed by Friday evening, and the lobby will reopen on Monday.', NULL, NULL, 'Select the best word for Blank 2: Employees should enter through the east doors and allow extra ____ in the morning.', 'time', 'times', 'timely', 'timed', 'A', 'Use context and grammar to complete the text.', NULL, NULL),
    ('6', 'reading', 'P6_SET_02', '1', 'Part 6: Read the text and choose the best answer for each blank.', 'Questions 133-134 refer to the following text.

Thank you for registering for the Small Business Finance Workshop. The event will be held in Hall B on June 18, and check-in starts at 8:30 a.m. Participants are encouraged to bring a notebook and a copy of the program schedule that was emailed last week.', NULL, NULL, 'Select the best word for Blank 1: The event will be held in Hall B on June 18, and check-in ____ at 8:30 a.m.', 'starts', 'start', 'starting', 'starter', 'A', 'Use context and grammar to complete the text.', NULL, NULL),
    ('6', 'reading', 'P6_SET_02', '2', 'Part 6: Read the text and choose the best answer for each blank.', 'Questions 133-134 refer to the following text.

Thank you for registering for the Small Business Finance Workshop. The event will be held in Hall B on June 18, and check-in starts at 8:30 a.m. Participants are encouraged to bring a notebook and a copy of the program schedule that was emailed last week.', NULL, NULL, 'Select the best word for Blank 2: Participants are encouraged to bring a notebook and a copy of the program schedule that was ____ last week.', 'emailed', 'email', 'emails', 'emailing', 'A', 'Use context and grammar to complete the text.', NULL, NULL),
    ('6', 'reading', 'P6_SET_03', '1', 'Part 6: Read the text and choose the best answer for each blank.', 'Questions 135-136 refer to the following text.

The Green Market has expanded its delivery area to include the northern suburbs. Orders placed before noon will arrive the same day, while later orders will be delivered the following morning. Customers can review the updated service map on the company website.', NULL, NULL, 'Select the best word for Blank 1: Orders placed before noon will arrive the same day, while later orders will be delivered the following ____.', 'morning', 'mornings', 'morningly', 'morn', 'A', 'Use context and grammar to complete the text.', NULL, NULL),
    ('6', 'reading', 'P6_SET_03', '2', 'Part 6: Read the text and choose the best answer for each blank.', 'Questions 135-136 refer to the following text.

The Green Market has expanded its delivery area to include the northern suburbs. Orders placed before noon will arrive the same day, while later orders will be delivered the following morning. Customers can review the updated service map on the company website.', NULL, NULL, 'Select the best word for Blank 2: Customers can review the updated service map on the company ____.', 'website', 'web', 'siteful', 'webbed', 'A', 'Use context and grammar to complete the text.', NULL, NULL),
    ('6', 'reading', 'P6_SET_04', '1', 'Part 6: Read the text and choose the best answer for each blank.', 'Questions 137-138 refer to the following text.

Please be advised that our customer support phone line will be unavailable from 1 p.m. to 2 p.m. today because of a system upgrade. During that time, inquiries may still be submitted through the online help form, and responses will be sent as soon as service resumes.', NULL, NULL, 'Select the best word for Blank 1: Our customer support phone line will be unavailable from 1 p.m. to 2 p.m. today because of a system ____.', 'upgrade', 'upgraded', 'upgrades', 'upgradingly', 'A', 'Use context and grammar to complete the text.', NULL, NULL),
    ('6', 'reading', 'P6_SET_04', '2', 'Part 6: Read the text and choose the best answer for each blank.', 'Questions 137-138 refer to the following text.

Please be advised that our customer support phone line will be unavailable from 1 p.m. to 2 p.m. today because of a system upgrade. During that time, inquiries may still be submitted through the online help form, and responses will be sent as soon as service resumes.', NULL, NULL, 'Select the best word for Blank 2: Responses will be sent as soon as service ____.', 'resumes', 'resume', 'resumed', 'resuming', 'A', 'Use context and grammar to complete the text.', NULL, NULL),
    ('6', 'reading', 'P6_SET_05', '1', 'Part 6: Read the text and choose the best answer for each blank.', 'Questions 139-140 refer to the following text.

Visitors to the History Museum are invited to join a guided tour of the new photography exhibition. Tours begin every hour at the information desk on the first floor. Because space is limited, guests are advised to reserve a place online before arriving.', NULL, NULL, 'Select the best word for Blank 1: Tours begin every hour at the information desk on the ____ floor.', 'first', 'one', 'single', 'initially', 'A', 'Use context and grammar to complete the text.', NULL, NULL),
    ('6', 'reading', 'P6_SET_05', '2', 'Part 6: Read the text and choose the best answer for each blank.', 'Questions 139-140 refer to the following text.

Visitors to the History Museum are invited to join a guided tour of the new photography exhibition. Tours begin every hour at the information desk on the first floor. Because space is limited, guests are advised to reserve a place online before arriving.', NULL, NULL, 'Select the best word for Blank 2: Because space is limited, guests are advised to ____ a place online before arriving.', 'reserve', 'reserved', 'reserving', 'reservation', 'A', 'Use context and grammar to complete the text.', NULL, NULL),
    ('6', 'reading', 'P6_SET_06', '1', 'Part 6: Read the text and choose the best answer for each blank.', 'Questions 141-142 refer to the following text.

The Lakeside Hotel is pleased to announce the completion of its rooftop garden. Hotel guests may now enjoy breakfast there on weekends, weather permitting. Reservations are recommended because the seating area is smaller than the main dining room.', NULL, NULL, 'Select the best word for Blank 1: Hotel guests may now enjoy breakfast there on weekends, weather ____.', 'permitting', 'permit', 'permitted', 'permits', 'A', 'Use context and grammar to complete the text.', NULL, NULL),
    ('6', 'reading', 'P6_SET_06', '2', 'Part 6: Read the text and choose the best answer for each blank.', 'Questions 141-142 refer to the following text.

The Lakeside Hotel is pleased to announce the completion of its rooftop garden. Hotel guests may now enjoy breakfast there on weekends, weather permitting. Reservations are recommended because the seating area is smaller than the main dining room.', NULL, NULL, 'Select the best word for Blank 2: Reservations are recommended because the seating area is ____ than the main dining room.', 'smaller', 'small', 'smallest', 'smalling', 'A', 'Use context and grammar to complete the text.', NULL, NULL),
    ('6', 'reading', 'P6_SET_07', '1', 'Part 6: Read the text and choose the best answer for each blank.', 'Questions 143-144 refer to the following text.

As part of our annual safety review, employees must update their emergency contact information by July 31. The form can be accessed through the internal website and should be completed by all full-time and part-time staff.', NULL, NULL, 'Select the best word for Blank 1: Employees must update their emergency contact information by ____.', 'July 31', 'small', 'desk', 'carefully', 'A', 'Use context and grammar to complete the text.', NULL, NULL),
    ('6', 'reading', 'P6_SET_07', '2', 'Part 6: Read the text and choose the best answer for each blank.', 'Questions 143-144 refer to the following text.

As part of our annual safety review, employees must update their emergency contact information by July 31. The form can be accessed through the internal website and should be completed by all full-time and part-time staff.', NULL, NULL, 'Select the best word for Blank 2: The form can be accessed through the internal website and should be completed by all full-time and ____ staff.', 'part-time', 'partly time', 'timing part', 'partial', 'A', 'Use context and grammar to complete the text.', NULL, NULL),
    ('6', 'reading', 'P6_SET_08', '1', 'Part 6: Read the text and choose the best answer for each blank.', 'Questions 145-146 refer to the following text.

Thank you for shopping at North Point Books. Customers who spend more than $50 in one visit are eligible for a discount on their next purchase. Ask for a membership card at the register to receive promotional emails and event invitations.', NULL, NULL, 'Select the best word for Blank 1: Customers who spend more than $50 in one visit are ____ for a discount on their next purchase.', 'eligible', 'eligibly', 'eligibility', 'elective', 'A', 'Use context and grammar to complete the text.', NULL, NULL),
    ('6', 'reading', 'P6_SET_08', '2', 'Part 6: Read the text and choose the best answer for each blank.', 'Questions 145-146 refer to the following text.

Thank you for shopping at North Point Books. Customers who spend more than $50 in one visit are eligible for a discount on their next purchase. Ask for a membership card at the register to receive promotional emails and event invitations.', NULL, NULL, 'Select the best word for Blank 2: Ask for a membership card at the register to receive promotional emails and event ____.', 'invitations', 'invites', 'inviting', 'inviteful', 'A', 'Use context and grammar to complete the text.', NULL, NULL),
    ('7', 'reading', 'P7_SET_01', '1', 'Part 7: Read the text and answer the questions.', 'Questions 147-149 refer to the following notice.

Notice to Residents
The apartment management office will inspect all smoke detectors on Wednesday between 1 p.m. and 4 p.m. Residents do not need to be home, but pets should be secured. Please contact the office if your unit will be unavailable during that time.', NULL, NULL, 'What is the purpose of the notice?', 'To announce smoke detector inspections.', 'To advertise an apartment for rent.', 'To explain a rent increase.', 'To invite residents to a meeting.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_01', '2', 'Part 7: Read the text and answer the questions.', 'Questions 147-149 refer to the following notice.

Notice to Residents
The apartment management office will inspect all smoke detectors on Wednesday between 1 p.m. and 4 p.m. Residents do not need to be home, but pets should be secured. Please contact the office if your unit will be unavailable during that time.', NULL, NULL, 'When will the inspections take place?', 'Wednesday afternoon.', 'Wednesday morning.', 'Thursday afternoon.', 'Friday evening.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_01', '3', 'Part 7: Read the text and answer the questions.', 'Questions 147-149 refer to the following notice.

Notice to Residents
The apartment management office will inspect all smoke detectors on Wednesday between 1 p.m. and 4 p.m. Residents do not need to be home, but pets should be secured. Please contact the office if your unit will be unavailable during that time.', NULL, NULL, 'What are residents asked to do?', 'Secure their pets.', 'Pay a maintenance fee.', 'Move out temporarily.', 'Visit the management office.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_02', '1', 'Part 7: Read the text and answer the questions.', 'Questions 150-152 refer to the following email.

From: Nina Park
To: Sales Team
Subject: Regional client visit

I will be visiting our Daegu clients next Thursday and Friday. If you have any updated product sheets or pricing lists that should be shared, please send them to me by Tuesday noon so I can include them in my presentation packet.', NULL, NULL, 'Why is Nina writing the email?', 'To request updated sales materials.', 'To cancel a trip.', 'To announce a promotion.', 'To invite staff to lunch.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_02', '2', 'Part 7: Read the text and answer the questions.', 'Questions 150-152 refer to the following email.

From: Nina Park
To: Sales Team
Subject: Regional client visit

I will be visiting our Daegu clients next Thursday and Friday. If you have any updated product sheets or pricing lists that should be shared, please send them to me by Tuesday noon so I can include them in my presentation packet.', NULL, NULL, 'When will Nina visit the clients?', 'Next Thursday and Friday.', 'This Tuesday.', 'Tomorrow afternoon.', 'At the end of the month.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_02', '3', 'Part 7: Read the text and answer the questions.', 'Questions 150-152 refer to the following email.

From: Nina Park
To: Sales Team
Subject: Regional client visit

I will be visiting our Daegu clients next Thursday and Friday. If you have any updated product sheets or pricing lists that should be shared, please send them to me by Tuesday noon so I can include them in my presentation packet.', NULL, NULL, 'What does Nina want by Tuesday noon?', 'Product sheets or pricing lists.', 'Hotel reservations.', 'Expense receipts.', 'Staff attendance reports.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_03', '1', 'Part 7: Read the text and answer the questions.', 'Questions 153-155 refer to the following article.

City Bike Share Expands
The City Bike Share program added 12 new stations this month, including three near university campuses. Officials say the expansion is intended to reduce traffic congestion and encourage more residents to use public transit for part of their daily commute.', NULL, NULL, 'What was added this month?', 'Twelve new bike stations.', 'Three new train lines.', 'A parking garage.', 'A highway toll system.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_03', '2', 'Part 7: Read the text and answer the questions.', 'Questions 153-155 refer to the following article.

City Bike Share Expands
The City Bike Share program added 12 new stations this month, including three near university campuses. Officials say the expansion is intended to reduce traffic congestion and encourage more residents to use public transit for part of their daily commute.', NULL, NULL, 'Where are some of the new stations located?', 'Near university campuses.', 'Inside shopping malls.', 'At the airport.', 'Beside the harbor.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_03', '3', 'Part 7: Read the text and answer the questions.', 'Questions 153-155 refer to the following article.

City Bike Share Expands
The City Bike Share program added 12 new stations this month, including three near university campuses. Officials say the expansion is intended to reduce traffic congestion and encourage more residents to use public transit for part of their daily commute.', NULL, NULL, 'Why was the program expanded?', 'To reduce congestion and encourage transit use.', 'To raise parking fees.', 'To support a bicycle race.', 'To close older stations.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_04', '1', 'Part 7: Read the text and answer the questions.', 'Questions 156-158 refer to the following advertisement.

Looking for office furniture at a lower price? Modern Workspace is offering 20 percent off all desks and shelving units through May 31. Free assembly is included for purchases over $500, and delivery is available throughout the capital region.', NULL, NULL, 'What is being advertised?', 'Office furniture.', 'A software package.', 'A moving service.', 'A design course.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_04', '2', 'Part 7: Read the text and answer the questions.', 'Questions 156-158 refer to the following advertisement.

Looking for office furniture at a lower price? Modern Workspace is offering 20 percent off all desks and shelving units through May 31. Free assembly is included for purchases over $500, and delivery is available throughout the capital region.', NULL, NULL, 'How long does the discount last?', 'Through May 31.', 'For one weekend only.', 'Until the end of the year.', 'Until inventory is counted.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_04', '3', 'Part 7: Read the text and answer the questions.', 'Questions 156-158 refer to the following advertisement.

Looking for office furniture at a lower price? Modern Workspace is offering 20 percent off all desks and shelving units through May 31. Free assembly is included for purchases over $500, and delivery is available throughout the capital region.', NULL, NULL, 'What is included for purchases over $500?', 'Free assembly.', 'A warranty extension.', 'A free computer chair.', 'Same-day pickup.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_05', '1', 'Part 7: Read the text and answer the questions.', 'Questions 159-161 refer to the following webpage.

Harbor Museum Hours
Tuesday-Friday: 10 a.m.-6 p.m.
Saturday-Sunday: 9 a.m.-7 p.m.
Closed Mondays
Special family workshops are held on the second Saturday of each month. Tickets can be purchased online or at the front desk.', NULL, NULL, 'When is the museum closed?', 'On Mondays.', 'On Tuesdays.', 'Every weekend.', 'Only on holidays.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_05', '2', 'Part 7: Read the text and answer the questions.', 'Questions 159-161 refer to the following webpage.

Harbor Museum Hours
Tuesday-Friday: 10 a.m.-6 p.m.
Saturday-Sunday: 9 a.m.-7 p.m.
Closed Mondays
Special family workshops are held on the second Saturday of each month. Tickets can be purchased online or at the front desk.', NULL, NULL, 'When are family workshops held?', 'On the second Saturday of each month.', 'Every Friday afternoon.', 'Every Sunday morning.', 'Once a year.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_05', '3', 'Part 7: Read the text and answer the questions.', 'Questions 159-161 refer to the following webpage.

Harbor Museum Hours
Tuesday-Friday: 10 a.m.-6 p.m.
Saturday-Sunday: 9 a.m.-7 p.m.
Closed Mondays
Special family workshops are held on the second Saturday of each month. Tickets can be purchased online or at the front desk.', NULL, NULL, 'How can tickets be purchased?', 'Online or at the front desk.', 'By phone only.', 'From nearby shops.', 'At the parking gate.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_06', '1', 'Part 7: Read the text and answer the questions.', 'Questions 162-164 refer to the following memo.

To: All Branch Managers
Please remind employees that inventory counts must be submitted by 6 p.m. each Friday. Branches that are using the new reporting software should attach both the digital spreadsheet and the summary checklist to the weekly email.', NULL, NULL, 'What must be submitted by Friday evening?', 'Inventory counts.', 'Travel claims.', 'Store keys.', 'Customer coupons.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_06', '2', 'Part 7: Read the text and answer the questions.', 'Questions 162-164 refer to the following memo.

To: All Branch Managers
Please remind employees that inventory counts must be submitted by 6 p.m. each Friday. Branches that are using the new reporting software should attach both the digital spreadsheet and the summary checklist to the weekly email.', NULL, NULL, 'Who is the memo addressed to?', 'Branch managers.', 'Warehouse drivers.', 'New interns.', 'Outside suppliers.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_06', '3', 'Part 7: Read the text and answer the questions.', 'Questions 162-164 refer to the following memo.

To: All Branch Managers
Please remind employees that inventory counts must be submitted by 6 p.m. each Friday. Branches that are using the new reporting software should attach both the digital spreadsheet and the summary checklist to the weekly email.', NULL, NULL, 'What should branches using new software attach?', 'A spreadsheet and a checklist.', 'Only a handwritten note.', 'A marketing poster.', 'A fuel receipt.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_07', '1', 'Part 7: Read the text and answer the questions.', 'Questions 165-167 refer to the following online review.

I recently stayed at the Pine Hill Lodge for two nights during a business trip. The room was quiet, the breakfast buffet had many options, and the staff helped me print meeting materials in the lobby business center. I would gladly stay there again.', NULL, NULL, 'What is being reviewed?', 'A hotel stay.', 'A restaurant delivery.', 'A taxi service.', 'A fitness class.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_07', '2', 'Part 7: Read the text and answer the questions.', 'Questions 165-167 refer to the following online review.

I recently stayed at the Pine Hill Lodge for two nights during a business trip. The room was quiet, the breakfast buffet had many options, and the staff helped me print meeting materials in the lobby business center. I would gladly stay there again.', NULL, NULL, 'What did the writer appreciate about breakfast?', 'There were many options.', 'It was served until noon.', 'It was included only on weekends.', 'It was delivered to the room.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_07', '3', 'Part 7: Read the text and answer the questions.', 'Questions 165-167 refer to the following online review.

I recently stayed at the Pine Hill Lodge for two nights during a business trip. The room was quiet, the breakfast buffet had many options, and the staff helped me print meeting materials in the lobby business center. I would gladly stay there again.', NULL, NULL, 'What did the staff help the writer do?', 'Print meeting materials.', 'Change a flight reservation.', 'Wash clothing.', 'Move luggage to another hotel.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_08', '1', 'Part 7: Read the text and answer the questions.', 'Questions 168-170 refer to the following notice and email.

[Notice]
The Lakeside Community Center will close its pool from July 3 to July 10 for routine maintenance. Fitness classes in Studio A will continue as scheduled.

[Email]
From: Aaron
To: Maya
I know you planned to swim next week, but the pool will be closed for maintenance. If you still want to exercise, I can join you for the Tuesday evening yoga class instead.', NULL, NULL, 'What facility will be closed?', 'The pool.', 'Studio A.', 'The front desk.', 'The parking lot.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_08', '2', 'Part 7: Read the text and answer the questions.', 'Questions 168-170 refer to the following notice and email.

[Notice]
The Lakeside Community Center will close its pool from July 3 to July 10 for routine maintenance. Fitness classes in Studio A will continue as scheduled.

[Email]
From: Aaron
To: Maya
I know you planned to swim next week, but the pool will be closed for maintenance. If you still want to exercise, I can join you for the Tuesday evening yoga class instead.', NULL, NULL, 'What will continue as scheduled?', 'Fitness classes in Studio A.', 'Swimming lessons.', 'Child-care services.', 'Basketball practice.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_08', '3', 'Part 7: Read the text and answer the questions.', 'Questions 168-170 refer to the following notice and email.

[Notice]
The Lakeside Community Center will close its pool from July 3 to July 10 for routine maintenance. Fitness classes in Studio A will continue as scheduled.

[Email]
From: Aaron
To: Maya
I know you planned to swim next week, but the pool will be closed for maintenance. If you still want to exercise, I can join you for the Tuesday evening yoga class instead.', NULL, NULL, 'What does Aaron suggest?', 'Attending a yoga class instead.', 'Waiting until August to exercise.', 'Using a different community center.', 'Requesting a refund immediately.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_09', '1', 'Part 7: Read the text and answer the questions.', 'Questions 171-173 refer to the following article and form.

[Article]
The annual River Clean-Up Day will be held on September 14. Volunteers will gather at 8 a.m. in Riverside Park and will receive gloves, trash bags, and refreshments.

[Form]
Volunteer Name: ____
Preferred Task: shoreline cleanup / registration table / refreshments
T-shirt Size: S / M / L / XL', NULL, NULL, 'What event is described?', 'River Clean-Up Day.', 'A charity concert.', 'A museum opening.', 'A school sports festival.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_09', '2', 'Part 7: Read the text and answer the questions.', 'Questions 171-173 refer to the following article and form.

[Article]
The annual River Clean-Up Day will be held on September 14. Volunteers will gather at 8 a.m. in Riverside Park and will receive gloves, trash bags, and refreshments.

[Form]
Volunteer Name: ____
Preferred Task: shoreline cleanup / registration table / refreshments
T-shirt Size: S / M / L / XL', NULL, NULL, 'What will volunteers receive?', 'Gloves, trash bags, and refreshments.', 'A transportation pass.', 'A bicycle helmet.', 'A hotel discount.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_09', '3', 'Part 7: Read the text and answer the questions.', 'Questions 171-173 refer to the following article and form.

[Article]
The annual River Clean-Up Day will be held on September 14. Volunteers will gather at 8 a.m. in Riverside Park and will receive gloves, trash bags, and refreshments.

[Form]
Volunteer Name: ____
Preferred Task: shoreline cleanup / registration table / refreshments
T-shirt Size: S / M / L / XL', NULL, NULL, 'What information is requested on the form?', 'A preferred task.', 'A passport number.', 'A meal receipt.', 'A banking code.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_10', '1', 'Part 7: Read the text and answer the questions.', 'Questions 174-176 refer to the following web article and message.

[Article]
Starting this month, the Metro Library app allows users to renew borrowed books, reserve study rooms, and receive reminders before due dates.

[Message]
Hi Jisoo, I used the library app to reserve a study room for Saturday morning. You should download it too because it also sends alerts before books are due.', NULL, NULL, 'What new service does the app provide?', 'Study room reservations.', 'Restaurant discounts.', 'Language lessons.', 'Parking validation.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_10', '2', 'Part 7: Read the text and answer the questions.', 'Questions 174-176 refer to the following web article and message.

[Article]
Starting this month, the Metro Library app allows users to renew borrowed books, reserve study rooms, and receive reminders before due dates.

[Message]
Hi Jisoo, I used the library app to reserve a study room for Saturday morning. You should download it too because it also sends alerts before books are due.', NULL, NULL, 'When was the study room reserved for?', 'Saturday morning.', 'Friday evening.', 'This afternoon.', 'Next month.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_10', '3', 'Part 7: Read the text and answer the questions.', 'Questions 174-176 refer to the following web article and message.

[Article]
Starting this month, the Metro Library app allows users to renew borrowed books, reserve study rooms, and receive reminders before due dates.

[Message]
Hi Jisoo, I used the library app to reserve a study room for Saturday morning. You should download it too because it also sends alerts before books are due.', NULL, NULL, 'Why does the writer recommend the app?', 'It sends due-date reminders.', 'It provides free textbooks.', 'It has a map of coffee shops.', 'It allows users to print for free.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_11', '1', 'Part 7: Read the text and answer the questions.', 'Questions 177-179 refer to the following flyer.

Join us for the Autumn Craft Fair at Maple Hall this Sunday from 11 a.m. to 5 p.m. Local artists will sell handmade jewelry, ceramics, and textile goods. Early visitors will receive a reusable shopping bag while supplies last.', NULL, NULL, 'What event is being promoted?', 'A craft fair.', 'A financial seminar.', 'A job interview day.', 'A warehouse sale.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_11', '2', 'Part 7: Read the text and answer the questions.', 'Questions 177-179 refer to the following flyer.

Join us for the Autumn Craft Fair at Maple Hall this Sunday from 11 a.m. to 5 p.m. Local artists will sell handmade jewelry, ceramics, and textile goods. Early visitors will receive a reusable shopping bag while supplies last.', NULL, NULL, 'What items will be sold?', 'Handmade goods.', 'Used office furniture.', 'Imported electronics.', 'Concert tickets.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_11', '3', 'Part 7: Read the text and answer the questions.', 'Questions 177-179 refer to the following flyer.

Join us for the Autumn Craft Fair at Maple Hall this Sunday from 11 a.m. to 5 p.m. Local artists will sell handmade jewelry, ceramics, and textile goods. Early visitors will receive a reusable shopping bag while supplies last.', NULL, NULL, 'What will early visitors receive?', 'A reusable shopping bag.', 'A free lunch.', 'A train voucher.', 'A pottery lesson.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_12', '1', 'Part 7: Read the text and answer the questions.', 'Questions 180-182 refer to the following letter.

Dear Subscribers,
Beginning in August, Home Garden Magazine will publish an additional digital issue each month featuring seasonal planting guides and video interviews with gardening experts. Printed subscriptions will continue unchanged.', NULL, NULL, 'What change is being announced?', 'An extra digital issue each month.', 'A price increase for printed copies.', 'A new office address.', 'A shorter subscription period.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_12', '2', 'Part 7: Read the text and answer the questions.', 'Questions 180-182 refer to the following letter.

Dear Subscribers,
Beginning in August, Home Garden Magazine will publish an additional digital issue each month featuring seasonal planting guides and video interviews with gardening experts. Printed subscriptions will continue unchanged.', NULL, NULL, 'What will the digital issue include?', 'Planting guides and video interviews.', 'Free seeds and tools.', 'Restaurant coupons.', 'Travel reviews.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_12', '3', 'Part 7: Read the text and answer the questions.', 'Questions 180-182 refer to the following letter.

Dear Subscribers,
Beginning in August, Home Garden Magazine will publish an additional digital issue each month featuring seasonal planting guides and video interviews with gardening experts. Printed subscriptions will continue unchanged.', NULL, NULL, 'What will happen to printed subscriptions?', 'They will continue unchanged.', 'They will be canceled.', 'They will become digital only.', 'They will be mailed weekly.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_13', '1', 'Part 7: Read the text and answer the questions.', 'Questions 183-185 refer to the following email and schedule.

[Email]
Please remember that our visiting speaker from Vancouver will arrive on Thursday evening. We need volunteers to greet her at the hotel and to prepare the seminar room before Friday''s session.

[Schedule]
Thursday 7:30 p.m. hotel welcome
Friday 8:00 a.m. room setup
Friday 10:00 a.m. seminar begins', NULL, NULL, 'Why is the email being sent?', 'To request volunteers.', 'To cancel the seminar.', 'To collect donations.', 'To reserve hotel rooms for staff.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_13', '2', 'Part 7: Read the text and answer the questions.', 'Questions 183-185 refer to the following email and schedule.

[Email]
Please remember that our visiting speaker from Vancouver will arrive on Thursday evening. We need volunteers to greet her at the hotel and to prepare the seminar room before Friday''s session.

[Schedule]
Thursday 7:30 p.m. hotel welcome
Friday 8:00 a.m. room setup
Friday 10:00 a.m. seminar begins', NULL, NULL, 'When does the seminar begin?', 'Friday at 10:00 a.m.', 'Thursday at 7:30 p.m.', 'Friday at 8:00 a.m.', 'Saturday morning.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_13', '3', 'Part 7: Read the text and answer the questions.', 'Questions 183-185 refer to the following email and schedule.

[Email]
Please remember that our visiting speaker from Vancouver will arrive on Thursday evening. We need volunteers to greet her at the hotel and to prepare the seminar room before Friday''s session.

[Schedule]
Thursday 7:30 p.m. hotel welcome
Friday 8:00 a.m. room setup
Friday 10:00 a.m. seminar begins', NULL, NULL, 'What happens on Thursday evening?', 'The speaker is welcomed at the hotel.', 'The seminar room is cleaned.', 'The seminar begins.', 'Volunteers attend training.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_14', '1', 'Part 7: Read the text and answer the questions.', 'Questions 186-188 refer to the following online posting.

For Sale: lightly used espresso machine, purchased last year for a cafe project. Includes metal frothing pitcher and instruction booklet. Pick-up is available near East Market Station, or local delivery can be arranged for an extra fee.', NULL, NULL, 'What item is for sale?', 'An espresso machine.', 'A train ticket.', 'A tablet computer.', 'A set of office shelves.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_14', '2', 'Part 7: Read the text and answer the questions.', 'Questions 186-188 refer to the following online posting.

For Sale: lightly used espresso machine, purchased last year for a cafe project. Includes metal frothing pitcher and instruction booklet. Pick-up is available near East Market Station, or local delivery can be arranged for an extra fee.', NULL, NULL, 'What is included with the item?', 'A pitcher and booklet.', 'A one-year warranty extension.', 'Free coffee beans.', 'A replacement filter only.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_14', '3', 'Part 7: Read the text and answer the questions.', 'Questions 186-188 refer to the following online posting.

For Sale: lightly used espresso machine, purchased last year for a cafe project. Includes metal frothing pitcher and instruction booklet. Pick-up is available near East Market Station, or local delivery can be arranged for an extra fee.', NULL, NULL, 'What delivery option is mentioned?', 'Local delivery for an extra fee.', 'International shipping at no charge.', 'Delivery only by train.', 'Pickup is not possible.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_15', '1', 'Part 7: Read the text and answer the questions.', 'Questions 189-191 refer to the following announcement and map.

[Announcement]
Beginning July 1, visitors to Green Valley Park must use the new west entrance while the south gate is repaired. Parking is available beside the visitor center.

[Map Summary]
West entrance -> visitor center parking -> lake trail', NULL, NULL, 'Which entrance should visitors use?', 'The west entrance.', 'The south gate.', 'The east service road.', 'The staff driveway.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_15', '2', 'Part 7: Read the text and answer the questions.', 'Questions 189-191 refer to the following announcement and map.

[Announcement]
Beginning July 1, visitors to Green Valley Park must use the new west entrance while the south gate is repaired. Parking is available beside the visitor center.

[Map Summary]
West entrance -> visitor center parking -> lake trail', NULL, NULL, 'Why is the change being made?', 'The south gate is being repaired.', 'The parking lot is expanding.', 'A festival is scheduled.', 'The park is closing early.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_15', '3', 'Part 7: Read the text and answer the questions.', 'Questions 189-191 refer to the following announcement and map.

[Announcement]
Beginning July 1, visitors to Green Valley Park must use the new west entrance while the south gate is repaired. Parking is available beside the visitor center.

[Map Summary]
West entrance -> visitor center parking -> lake trail', NULL, NULL, 'Where is parking available?', 'Beside the visitor center.', 'Along the lake trail.', 'At the south gate.', 'Near the maintenance shed.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_16', '1', 'Part 7: Read the text and answer the questions.', 'Questions 192-194 refer to the following report and email.

[Report]
The customer survey showed that delivery speed improved significantly after the company added two evening drivers in March. However, respondents still requested better package tracking updates.

[Email]
Thanks for sharing the survey. Let''s discuss the tracking issue in next week''s operations meeting and see whether the app team can help.', NULL, NULL, 'What improved after March?', 'Delivery speed.', 'Advertising costs.', 'Office attendance.', 'Printer maintenance.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_16', '2', 'Part 7: Read the text and answer the questions.', 'Questions 192-194 refer to the following report and email.

[Report]
The customer survey showed that delivery speed improved significantly after the company added two evening drivers in March. However, respondents still requested better package tracking updates.

[Email]
Thanks for sharing the survey. Let''s discuss the tracking issue in next week''s operations meeting and see whether the app team can help.', NULL, NULL, 'What did customers still want?', 'Better tracking updates.', 'Longer store hours.', 'A free loyalty card.', 'More evening drivers.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_16', '3', 'Part 7: Read the text and answer the questions.', 'Questions 192-194 refer to the following report and email.

[Report]
The customer survey showed that delivery speed improved significantly after the company added two evening drivers in March. However, respondents still requested better package tracking updates.

[Email]
Thanks for sharing the survey. Let''s discuss the tracking issue in next week''s operations meeting and see whether the app team can help.', NULL, NULL, 'What does the writer suggest doing next?', 'Discussing the issue at an operations meeting.', 'Hiring more drivers immediately.', 'Repeating the survey tomorrow.', 'Closing the app team office.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_17', '1', 'Part 7: Read the text and answer the questions.', 'Questions 195-197 refer to the following brochure and memo.

[Brochure]
The Seaside Business Hotel offers discounted weekday rates for conference attendees. Guests may use the business lounge, complimentary Wi-Fi, and airport shuttle service.

[Memo]
Please book rooms at the Seaside Business Hotel for our conference speakers. The shuttle service will make airport arrivals easier, and the weekday discount will help us stay within budget.', NULL, NULL, 'Who receives discounted rates?', 'Conference attendees.', 'Weekend tourists only.', 'Airport employees.', 'Students.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_17', '2', 'Part 7: Read the text and answer the questions.', 'Questions 195-197 refer to the following brochure and memo.

[Brochure]
The Seaside Business Hotel offers discounted weekday rates for conference attendees. Guests may use the business lounge, complimentary Wi-Fi, and airport shuttle service.

[Memo]
Please book rooms at the Seaside Business Hotel for our conference speakers. The shuttle service will make airport arrivals easier, and the weekday discount will help us stay within budget.', NULL, NULL, 'What service is specifically mentioned in both texts?', 'Airport shuttle service.', 'Spa treatment.', 'Valet parking.', 'Laundry delivery.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_17', '3', 'Part 7: Read the text and answer the questions.', 'Questions 195-197 refer to the following brochure and memo.

[Brochure]
The Seaside Business Hotel offers discounted weekday rates for conference attendees. Guests may use the business lounge, complimentary Wi-Fi, and airport shuttle service.

[Memo]
Please book rooms at the Seaside Business Hotel for our conference speakers. The shuttle service will make airport arrivals easier, and the weekday discount will help us stay within budget.', NULL, NULL, 'Why does the memo writer prefer this hotel?', 'It is convenient and cost-effective.', 'It is the newest hotel in the city.', 'It has the largest ballroom.', 'It is nearest to the beach.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_18', '1', 'Part 7: Read the text and answer the questions.', 'Questions 198-200 refer to the following article and message board post.

[Article]
The Hilltop Farmers'' Market will relocate to Pine Square for the summer because construction is underway at its usual location. Vendors will continue to operate on Saturdays from 8 a.m. to 1 p.m.

[Post]
Thanks for sharing the update. Pine Square is actually closer to my office, so I''ll be able to stop by the market before work this Saturday.', NULL, NULL, 'Why is the market relocating?', 'Construction is underway at the usual location.', 'The vendors requested shorter hours.', 'The city canceled Saturday events.', 'The market is expanding internationally.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_18', '2', 'Part 7: Read the text and answer the questions.', 'Questions 198-200 refer to the following article and message board post.

[Article]
The Hilltop Farmers'' Market will relocate to Pine Square for the summer because construction is underway at its usual location. Vendors will continue to operate on Saturdays from 8 a.m. to 1 p.m.

[Post]
Thanks for sharing the update. Pine Square is actually closer to my office, so I''ll be able to stop by the market before work this Saturday.', NULL, NULL, 'When will the market operate?', 'On Saturdays from 8 a.m. to 1 p.m.', 'Every weekday at noon.', 'Only on Sunday evenings.', 'On Fridays after work.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL),
    ('7', 'reading', 'P7_SET_18', '3', 'Part 7: Read the text and answer the questions.', 'Questions 198-200 refer to the following article and message board post.

[Article]
The Hilltop Farmers'' Market will relocate to Pine Square for the summer because construction is underway at its usual location. Vendors will continue to operate on Saturdays from 8 a.m. to 1 p.m.

[Post]
Thanks for sharing the update. Pine Square is actually closer to my office, so I''ll be able to stop by the market before work this Saturday.', NULL, NULL, 'Why is the writer pleased about the move?', 'The new location is closer to the office.', 'Parking is now free for vendors.', 'The market will open earlier on weekdays.', 'The construction will end this week.', 'A', 'Find the answer that matches the information in the passage.', NULL, NULL);

SET FOREIGN_KEY_CHECKS = 1;