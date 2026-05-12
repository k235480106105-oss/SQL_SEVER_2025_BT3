# Bài tập môn Hệ quản trị cơ sở dữ liệu-TEE560, Lớp: 59KMT
## BÀI TẬP VỀ NHÀ 03: THIẾT KẾ VÀ CÀI ĐẶT CSDL QUẢN LÝ CẦM ĐỒ
Nhiệm vụ: Cài đặt SQL
### Event 1: Đăng ký hợp đồng mới
Khai báo thiết lập đầu vào
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/45d268c2-5ff5-48b0-bad7-b36377303b39" />

Xử lý thông tin khách hàng (tránh trùng lặp)
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/de14cead-a1cc-4ffb-a37b-285bfc72ac96" />

Tạo hợp đồng
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/0a0c7413-054f-4b70-8538-f89c2e9e1249" />

Thêm danh sách tài sản
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/ec350c41-ae06-4d6d-9d81-1c2d77287ebb" />

### Event 2: Tính toán công nợ thời gian thực
1. Hàm tính tổng tiền (gốc + lãi) của cả hợp đồng tại một thời 
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/78c3939c-2b99-4b77-a577-17dfba24d5ed" />

2. Hàm để tính toán số tiền phát sinh của một biến động cụ thể (VD: lãi phát sinh thêm giữa 2 lần trả tiền)
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/fd9e2789-84fa-419e-aa67-3e3bcec83d9f" />

3. tạo các bảng
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/d3c76c91-82f5-44b8-a213-22dca4d5ccc2" />

4. Thêm khách hàng
5. <img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/fb05c391-7e75-4b87-a91b-9f5a87ffcbd7" />

5. Tính số tiền thay đổi ở những thời điểm khác nhau
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/3add7c5c-afdd-441b-85a6-476054409dc3" />

### Event 3: Xử lý trả nợ và hoàn trả tài sản
1. Viết Store Procedure xử lý khi khách mang tiền đến
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/eb77c5cd-61c5-4987-80b3-4a79551c03a5" />

2. Kiểm tra dữ liệu nợ hiện tại
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/c8d97ae4-2423-4289-b0a6-6a6a65e67f6c" />

3. Chạy lệnh "trả tiền"
Giả sử khách mang đến 2.000.000đ để trả nợ cho hợp đồng số 1, bạn chạy lệnh EXEC như sau:
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/311c7668-6fa5-438a-9199-493be149e0b3" />

4. Xác nhận thay đổi trong CSDL
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/5eef8a12-9cfd-4fae-aef7-cdd7638e7471" />

5. Xem có dòng ghi nhận khách vừa trả 2 triệu hay không (ở bảng nhật ký Log).
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/587abda4-14e7-4dc7-876a-ef86bdfd9706" />

### Event 4: Truy vấn danh sách nợ xấu
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/d4750cb5-4e12-4857-8a23-5eb19183507c" />

Giả sử hợp đồng số 1 đã quá hạn từ 1 tháng trước
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/7ff07813-3b81-4ef1-b453-41704a9cc467" />

Kiểm tra nợ xấu
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/501f204b-c0cf-43bb-800c-36f620d59ec7" />

### Event 5: Quản lý thanh lý tài 
1. Viết một Trigger tự động chuyển trạng thái hợp đồng sang "Quá hạn (nợ xấu)" sau khi hợp
đồng đang ở trạng thái "Đang vay" mà ngày vượt quá Deadline 1.
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/36c222bc-3d74-47d7-8bb8-c8de7477c05d" />

Kiểm tra kết quả:
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/3d6fc47d-8f6c-4b8e-ba7f-08f8f3a94c8c" />

2. Viết một Trigger tự động chuyển trạng thái tài sản sang "Sẵn sàng thanh lý" sau khi hợp
đồng đang ở trạng thái "Quá hạn (nợ xấu)" mà ngày vượt quá Deadline 2.
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/9cda075d-7f9a-4b31-be8e-1015cc84cd8e" />

Kiểm tra kết quả:
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/bbc3169d-9806-4967-bba8-ee0214f605ff" />


3. Viết một Trigger tự động chuyển trạng thái tài sản thành “Đã bán thanh lý” sau khi trạng
thái của hợp đồng chuyển sang "Đã thanh lý".
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/948c4b94-f5b3-4e77-9a22-7371d6e2e28c" />

Kiểm tra kết quả
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/036d83f7-2521-4744-befd-49e2abe48af2" />

### Các sự kiện bổ sung
1. Procedure gia hạn hợp đồng
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/6d2e866d-9cef-42aa-bf03-da541faa3dc9" />

2. Gia hạn hợp đồng: giả sử khách đến đóng tiền lãi để dời lịch trả
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/3ede7d4a-c11e-45d8-b3cd-e07a2b7fe692" />

3. Kiểm tra nhật ký dòng tiền
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/83c99a4f-07ff-4df6-b73b-315d35e265e6" />

4. Kiểm tra trạng thái tài: Sau khi nợ quá hạn hoặc thanh
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/669d3c26-4881-4d6c-8070-f478fdda8d40" />
