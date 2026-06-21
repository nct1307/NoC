# 🚀 Multi-core SoC based on 2D-Mesh Network-on-Chip (NoC)

NguyenChiThanh - VoThaiDuy

---

## 🌟 Tính năng nổi bật (Key Features)

* **Vi xử lý Đa lõi (Multi-core):** Tích hợp 4 lõi CPU kiến trúc tập lệnh **RISC-V (RV32I)**, có khả năng thực thi các tác vụ độc lập và chạy song song (Concurrency).
* **Kiến trúc Mạng NoC 3x3:** Thay thế cấu trúc Shared Bus truyền thống bằng mạng 2D-Mesh. Sử dụng Router Stanford với thuật toán định tuyến **XY Routing**, đảm bảo luồng dữ liệu thông suốt và chống kẹt mạng (Deadlock-free).
* **Giao thức Đồng bộ:** Triển khai chuẩn giao tiếp **Wishbone** qua khối Network Interface (NI). Triệt tiêu hoàn toàn lỗi "Gói tin bóng ma" (Ghost Transaction) nhờ tích hợp trạng thái khóa `Bus_Wait` (S_DONE) trong FSM.
* **Hệ sinh thái Ngoại vi phong phú:** Bao gồm Shared RAM (4KB), LED Matrix, Hardware Timer, UART, và GPIO.
* **Hiệu năng vượt trội (Tổng hợp trên Xilinx Kintex-7):**
    * Tần số hoạt động cực đại ($F_{max}$): **> 100 MHz** (WNS = +0.050 ns).
    * Băng thông liên kết (Link Bandwidth): **400 MB/s** trên mỗi đường truyền 32-bit.
    * Công suất tiêu thụ siêu thấp: **145 mW**.

---

## 🗺️ Kiến trúc Hệ thống & Bản đồ Địa chỉ (MMIO)

Hệ thống áp dụng cơ chế Memory Mapped I/O, gom toàn bộ thiết bị lên một không gian địa chỉ 32-bit duy nhất. Khối NI sẽ tự động trích xuất 4-bit MSB (Mã vùng) để giải mã thành Tọa độ vật lý (X,Y) trên mạng NoC.

| Mã vùng (4-bit MSB) | Thiết bị Đích (IP Core) | Tọa độ NoC (X, Y) | Chức năng chính |
| :--- | :--- | :--- | :--- |
| **`0x0`** | Shared RAM | (1, 1) | Bộ nhớ dùng chung đa lõi |
| **`0x1`** | LED Matrix | (2, 1) | Hiển thị đồ họa / Debug |
| **`0x2`** | Hardware Timer | (0, 1) | Bộ định thời hệ thống |
| **`0x4`** | UART Module | (1, 2) | Truyền thông nối tiếp |

---

## 🛠️ Công cụ và Nền tảng phát triển

* **Ngôn ngữ thiết kế:** Verilog HDL / SystemVerilog.
* **Mô phỏng (Simulation):** ModelSim / QuestaSim (Hỗ trợ kịch bản TCL tự động hóa).
* **Tổng hợp & Đánh giá (Synthesis & Implementation):** AMD Xilinx Vivado.
* **Phần cứng mục tiêu:** Kit FPGA Xilinx Kintex-7 (`xc7k...`).

---

## 📊 Đánh giá Hiệu năng & Kết quả Mô phỏng

### 1. Mô phỏng Thực thi Song song (Full System Integration)
Hệ thống duy trì tính toàn vẹn dữ liệu và độ trễ thấp ngay cả khi 4 lõi RISC-V đồng thời truy xuất ngoại vi và bộ nhớ.
*(Ảnh minh họa: Cả 4 tín hiệu `wb_cyc` của 4 Core được kích hoạt đan xen, mạng NoC định tuyến song song không nghẽn cổ chai).*


### 2. Tối ưu Năng lượng & Diện tích (Synthesis Report)
Báo cáo Implementation từ Vivado chứng minh hệ thống đạt độ tối ưu cao về kiến trúc cổng logic:
* **Logic Utilization:** ~19,000 LUTs (46%) & 38,000 FFs (47%) trên Kintex-7.
* **Power Consumption:** Tiêu thụ vỏn vẹn **0.145 W** (Dynamic: 0.064W, Static: 0.081W). Nhiệt độ tiếp giáp đạt 25.4°C.



### 3. Đạt chuẩn Thời gian (Timing Closure)
Thiết kế hoàn toàn đáp ứng các ràng buộc khắt khe nhất (No Timing Violations) ở nhịp clock 10ns (100MHz).
* **WNS (Worst Negative Slack):** +0.050 ns.



---

