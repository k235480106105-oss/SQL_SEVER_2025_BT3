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

Giả sử hợp đồng số 1 đã quá hạn từ 1 tháng trướ
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/7ff07813-3b81-4ef1-b453-41704a9cc467" />

Kiểm tra nợ xấu
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/501f204b-c0cf-43bb-800c-36f620d59ec7" />
