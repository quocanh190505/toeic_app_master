-- ==========================================
-- 1. THÊM 7 CHỦ ĐỀ VÀO BẢNG TOPICS
-- ==========================================
INSERT INTO topics (name, description, image_url) VALUES 
('Contracts', 'Từ vựng chủ đề Hợp đồng', 'https://cdn-icons-png.flaticon.com/512/2951/2951460.png'),
('Office', 'Từ vựng chủ đề Văn phòng', 'https://cdn-icons-png.flaticon.com/512/167/167707.png'),
('Human Resources', 'Từ vựng chủ đề Nhân sự', 'https://cdn-icons-png.flaticon.com/512/3126/3126647.png'),
('Purchasing', 'Từ vựng chủ đề Mua sắm', 'https://cdn-icons-png.flaticon.com/512/3144/3144456.png'),
('Marketing', 'Từ vựng chủ đề Tiếp thị', 'https://cdn-icons-png.flaticon.com/512/1998/1998087.png'),
('Travel', 'Từ vựng chủ đề Du lịch và Công tác', 'https://cdn-icons-png.flaticon.com/512/2060/2060284.png'),
('Finance', 'Từ vựng chủ đề Tài chính Kế toán', 'https://cdn-icons-png.flaticon.com/512/2933/2933116.png');

-- ==========================================
-- 2. THÊM TỪ VỰNG CHO TỪNG CHỦ ĐỀ
-- ==========================================

-- Topic 1: Contracts (Hợp đồng)
INSERT INTO vocabulary_words (word, meaning, example, topic_id) VALUES 
('Abide by', 'Tuân thủ', 'The two parties agreed to abide by the judge''s decision.', 1),
('Agreement', 'Thỏa thuận, hợp đồng', 'The agreement was signed by both parties.', 1),
('Assurance', 'Sự đảm bảo', 'He gave me his assurance that the contract would be signed today.', 1),
('Cancellation', 'Sự hủy bỏ', 'The cancellation of the contract caused a lot of problems.', 1),
('Determine', 'Xác định, quyết định', 'The terms of the contract determine the responsibilities of each party.', 1),
('Engage', 'Tham gia, cam kết', 'We engaged a lawyer to review the terms of the contract.', 1),
('Establish', 'Thành lập, thiết lập', 'The contract establishes the rights of both sides.', 1),
('Obligate', 'Bắt buộc, ép buộc', 'The contract obligates the firm to complete the project by May.', 1),
('Party', 'Bên (trong hợp đồng)', 'Both parties must sign the agreement for it to be valid.', 1),
('Provision', 'Điều khoản', 'The contract contains a provision for early termination.', 1),
('Resolve', 'Giải quyết', 'The mediator helped resolve the dispute between the two parties.', 1),
('Specific', 'Cụ thể, rõ ràng', 'The contract makes specific mention of the delivery date.', 1),
('Attract', 'Thu hút', 'The new terms were designed to attract more investors.', 1),
('Compare', 'So sánh', 'Please compare the current contract with the previous one.', 1),
('Competition', 'Sự cạnh tranh', 'The company faces strict competition in the market.', 1),
('Consume', 'Tiêu thụ', 'The negotiation process consumed a lot of time.', 1),
('Convince', 'Thuyết phục', 'We tried to convince them to sign the agreement.', 1),
('Currently', 'Hiện tại', 'The contract is currently under review.', 1),
('Fad', 'Mốt nhất thời', 'This type of contract might just be a passing fad.', 1),
('Inspire', 'Truyền cảm hứng', 'The successful negotiation inspired the whole team.', 1);

-- Topic 2: Office (Văn phòng)
INSERT INTO vocabulary_words (word, meaning, example, topic_id) VALUES 
('Access', 'Truy cập, quyền truy cập', 'You need a password to access the computer system.', 2),
('Allocate', 'Phân bổ', 'The office manager allocated the new computers to the design team.', 2),
('Compatible', 'Tương thích', 'This software is not compatible with our office computers.', 2),
('Delete', 'Xóa', 'Be careful not to delete any important office files.', 2),
('Display', 'Hiển thị, màn hình', 'The error message was displayed on the screen.', 2),
('Duplicate', 'Sao chép, bản sao', 'Please make a duplicate of this report for the meeting.', 2),
('Failure', 'Sự thất bại, hỏng hóc', 'The power failure caused the office computers to shut down.', 2),
('Figure out', 'Tìm hiểu, giải quyết', 'The IT support team is trying to figure out the problem.', 2),
('Ignore', 'Bỏ qua', 'Do not ignore the warning signs on your computer.', 2),
('Search', 'Tìm kiếm', 'I had to search through my emails to find the document.', 2),
('Shut down', 'Tắt máy', 'Please shut down your computer before leaving the office.', 2),
('Warning', 'Cảnh báo', 'The system gave a warning before it crashed.', 2),
('Affordable', 'Giá cả phải chăng', 'The company is looking for affordable office supplies.', 2),
('As needed', 'Khi cần thiết', 'Office supplies can be ordered as needed.', 2),
('Capacity', 'Sức chứa, công suất', 'The new printer has a higher paper capacity.', 2),
('Initiative', 'Sáng kiến, sự khởi xướng', 'Employees are encouraged to take the initiative.', 2),
('Physical', 'Thuộc về vật chất, thể chất', 'The physical layout of the office was changed.', 2),
('Provider', 'Nhà cung cấp', 'We need to find a new internet service provider.', 2),
('Recur', 'Tái diễn, lặp lại', 'The software issue seems to recur every week.', 2),
('Reduction', 'Sự giảm bớt', 'There has been a reduction in the office budget.', 2);

-- Topic 3: Human Resources (Nhân sự)
INSERT INTO vocabulary_words (word, meaning, example, topic_id) VALUES 
('Recruit', 'Tuyển dụng', 'The company plans to recruit 50 new staff members this year.', 3),
('Applicant', 'Người nộp đơn ứng tuyển', 'Every applicant must submit a copy of their resume.', 3),
('Interview', 'Phỏng vấn', 'She has a job interview tomorrow morning.', 3),
('Qualification', 'Bằng cấp, năng lực', 'He has the right qualifications for the management position.', 3),
('Hire', 'Thuê, mướn', 'We decided to hire him because of his extensive experience.', 3),
('Orientation', 'Sự định hướng (cho nhân viên mới)', 'New employees must attend a two-day orientation.', 3),
('Benefit', 'Phúc lợi', 'The job offers excellent health and dental benefits.', 3),
('Promote', 'Thăng chức', 'She was promoted to senior manager after two years.', 3),
('Resign', 'Từ chức, thôi việc', 'The CEO announced that he will resign next month.', 3),
('Retire', 'Nghỉ hưu', 'Most people in this company retire at the age of 60.', 3),
('Candidate', 'Ứng cử viên', 'We are looking for a candidate with strong leadership skills.', 3),
('Evaluate', 'Đánh giá', 'Performance is evaluated at the end of every quarter.', 3),
('Background', 'Lý lịch, nền tảng', 'They will do a background check on all potential employees.', 3),
('Compensate', 'Đền bù, trả lương', 'Employees will be compensated for any overtime hours worked.', 3),
('Match', 'Phù hợp, tương xứng', 'We try to match the right person to the right job.', 3),
('Profile', 'Hồ sơ', 'Please update your employee profile on the internal system.', 3),
('Submit', 'Nộp, đệ trình', 'All applications must be submitted by Friday.', 3),
('Time-consuming', 'Tốn thời gian', 'The recruitment process can be quite time-consuming.', 3),
('Train', 'Đào tạo', 'We will train you on how to use the new software.', 3),
('Wage', 'Tiền lương (thường tính theo giờ/tuần)', 'The minimum wage is expected to increase next year.', 3);

-- Topic 4: Purchasing (Mua sắm)
INSERT INTO vocabulary_words (word, meaning, example, topic_id) VALUES 
('Order', 'Đặt hàng, đơn hàng', 'We need to place an order for more printer ink.', 4),
('Supply', 'Cung cấp, nguồn cung', 'The company supplies office furniture to local businesses.', 4),
('Vendor', 'Nhà cung cấp', 'We are looking for a new vendor for our packaging materials.', 4),
('Invoice', 'Hóa đơn', 'Please pay the invoice within 30 days of receipt.', 4),
('Discount', 'Giảm giá', 'We offer a 10% discount for bulk orders.', 4),
('Inventory', 'Hàng tồn kho', 'We need to check the inventory before ordering more stock.', 4),
('Purchase', 'Mua sắm', 'The manager approved the purchase of new computers.', 4),
('Quantity', 'Số lượng', 'Please specify the quantity you wish to order.', 4),
('Receive', 'Nhận', 'We expect to receive the shipment by tomorrow.', 4),
('Catalog', 'Danh mục sản phẩm', 'You can find our full range of products in the new catalog.', 4),
('Estimate', 'Bảng ước tính giá', 'The contractor gave us an estimate for the repair work.', 4),
('Bargain', 'Mặc cả, món hời', 'These shoes were a real bargain at half price.', 4),
('Checkout', 'Thanh toán (tại quầy/online)', 'Your total will be calculated at checkout.', 4),
('Expand', 'Mở rộng', 'We plan to expand our product line next year.', 4),
('Explore', 'Khám phá, tìm hiểu', 'We should explore different options before making a decision.', 4),
('Item', 'Món hàng, khoản', 'Please check each item on the delivery list.', 4),
('Mandatory', 'Bắt buộc', 'It is mandatory to wear a helmet on the construction site.', 4),
('Merchandise', 'Hàng hóa', 'All merchandise must be paid for before leaving the store.', 4),
('Charge', 'Tính phí', 'They will charge a small fee for delivery.', 4),
('Refund', 'Hoàn tiền', 'If you are not satisfied, we will give you a full refund.', 4);

-- Topic 5: Marketing (Tiếp thị)
INSERT INTO vocabulary_words (word, meaning, example, topic_id) VALUES 
('Campaign', 'Chiến dịch', 'The new marketing campaign was very successful.', 5),
('Target', 'Mục tiêu', 'Our target audience is young adults aged 18 to 25.', 5),
('Advertise', 'Quảng cáo', 'We plan to advertise our new product on television.', 5),
('Brand', 'Thương hiệu', 'Building a strong brand takes time and effort.', 5),
('Launch', 'Ra mắt', 'The company will launch its new smartphone next week.', 5),
('Publicize', 'Quảng bá', 'We are using social media to publicize the upcoming event.', 5),
('Sponsor', 'Tài trợ', 'The local bank is sponsoring the charity marathon.', 5),
('Survey', 'Khảo sát', 'We conducted a customer satisfaction survey.', 5),
('Strategy', 'Chiến lược', 'They need to rethink their marketing strategy.', 5),
('Market', 'Thị trường', 'The housing market is slowly starting to recover.', 5),
('Analyze', 'Phân tích', 'The team will analyze the data from the recent campaign.', 5),
('Announce', 'Thông báo', 'The CEO will announce the new product line today.', 5),
('Compete', 'Cạnh tranh', 'Small businesses often find it hard to compete with large corporations.', 5),
('Consumer', 'Người tiêu dùng', 'Consumer demand for eco-friendly products is rising.', 5),
('Impact', 'Tác động, ảnh hưởng', 'The advertisement had a huge impact on sales.', 5),
('Innovative', 'Đổi mới, sáng tạo', 'She came up with an innovative approach to marketing.', 5),
('Position', 'Định vị', 'We need to position our brand as a premium choice.', 5),
('Predict', 'Dự đoán', 'It is hard to predict future consumer behavior.', 5),
('Preference', 'Sự ưa thích', 'Customer preferences are always changing.', 5),
('Trend', 'Xu hướng', 'We must stay up to date with the latest market trends.', 5);

-- Topic 6: Travel (Du lịch & Công tác)
INSERT INTO vocabulary_words (word, meaning, example, topic_id) VALUES 
('Flight', 'Chuyến bay', 'My flight to Tokyo departs at 8 AM.', 6),
('Passenger', 'Hành khách', 'All passengers must fasten their seatbelts.', 6),
('Destination', 'Điểm đến', 'Paris is a popular tourist destination.', 6),
('Itinerary', 'Lịch trình', 'I will send you the travel itinerary by email.', 6),
('Accommodation', 'Chỗ ở', 'The price of the tour includes flights and accommodation.', 6),
('Reservation', 'Sự đặt chỗ', 'I have a reservation under the name of Smith.', 6),
('Delay', 'Trì hoãn', 'The flight was delayed due to bad weather.', 6),
('Board', 'Lên tàu/máy bay', 'We will begin boarding the plane in 15 minutes.', 6),
('Depart', 'Khởi hành', 'The train departs from platform 4.', 6),
('Arrive', 'Đến nơi', 'We are expected to arrive in London at noon.', 6),
('Baggage', 'Hành lý', 'Please do not leave your baggage unattended.', 6),
('Check-in', 'Làm thủ tục', 'You need to check in at least two hours before the flight.', 6),
('Customs', 'Hải quan', 'It took us an hour to get through customs.', 6),
('Passport', 'Hộ chiếu', 'Make sure your passport is valid for at least six months.', 6),
('Ticket', 'Vé', 'Can I see your ticket and ID, please?', 6),
('Confirm', 'Xác nhận', 'Please confirm your flight 24 hours in advance.', 6),
('Fare', 'Giá vé', 'Train fares are going up again next month.', 6),
('Guide', 'Hướng dẫn viên', 'Our tour guide was very knowledgeable about the local history.', 6),
('Route', 'Tuyến đường', 'We took a scenic route along the coast.', 6),
('Vehicle', 'Phương tiện giao thông', 'Only authorized vehicles can park here.', 6);

-- Topic 7: Finance & Accounting (Tài chính Kế toán)
INSERT INTO vocabulary_words (word, meaning, example, topic_id) VALUES 
('Audit', 'Kiểm toán', 'An independent company will conduct the annual financial audit.', 7),
('Budget', 'Ngân sách', 'We need to keep the project within budget.', 7),
('Deficit', 'Thâm hụt', 'The government is trying to reduce the national deficit.', 7),
('Profit', 'Lợi nhuận', 'The company reported a record profit this quarter.', 7),
('Revenue', 'Doanh thu', 'Advertising revenue has increased significantly.', 7),
('Tax', 'Thuế', 'Don''t forget to file your tax return by April 15th.', 7),
('Invest', 'Đầu tư', 'He decided to invest his savings in the stock market.', 7),
('Loan', 'Khoản vay', 'She took out a bank loan to start her business.', 7),
('Debt', 'Nợ', 'The company is struggling to pay off its debts.', 7),
('Asset', 'Tài sản', 'The building is the company''s most valuable asset.', 7),
('Liability', 'Nghĩa vụ nợ, trách nhiệm pháp lý', 'The business has more liabilities than assets right now.', 7),
('Calculate', 'Tính toán', 'Please calculate the total cost including shipping.', 7),
('Forecast', 'Dự báo', 'The sales forecast for next year looks promising.', 7),
('Transaction', 'Giao dịch', 'There is a small fee for every international transaction.', 7),
('Balance', 'Số dư (tài khoản)', 'I checked my bank balance this morning.', 7),
('Deposit', 'Gửi tiền, đặt cọc', 'I need to deposit this check into my account.', 7),
('Withdraw', 'Rút tiền', 'You can withdraw up to $500 a day from the ATM.', 7),
('Interest', 'Lãi suất', 'The interest rate on this loan is very high.', 7),
('Capital', 'Vốn', 'They need to raise more capital to expand the business.', 7),
('Expense', 'Chi phí', 'Travel expenses will be reimbursed by the company.', 7);
