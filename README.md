**📊 Phân Tích Tai Nạn Giao Thông Tại Việt Nam (2023–2024)**

**🔍 Tổng quan**

Repository này chứa toàn bộ quá trình phân tích dữ liệu tai nạn giao thông tại Việt Nam trong giai đoạn từ năm 2023 đến 2024. 
Mục tiêu là khám phá xu hướng thay đổi theo thời gian, xác định các thời điểm cao điểm theo các nguyên nhân gây tai nạn và trình bày song song những đề suất tương ứng để cải thiện giao thông đường bộ.

**🎯 Mục tiêu phân tích**
- Quan sát xu hướng của tai nạn giao thông trong hai năm 2023 và 2024.
- Quan sát chu kỳ xảy ra tại nạn giao thông gây ra bởi các nguyên nhân.
- Trình bày thời gian cao điểm của tai nạn giao thông.
- Trình bày tình hình thực tế ở các thời điểm xảy ra tai nạn giao thông.


**📁 Cấu trúc repository**

├── traffic_accident_summary_exploration [Here](https://github.com/VoTuan0512/traffic-accident-prophet-model/blob/master/traffic_accident_summary_exploration.sql)              --> trình bày những truy vấn cơ bản để mô tả dữ liệu

├── traffic_accident_time_series_analysis [Here](https://github.com/VoTuan0512/traffic-accident-prophet-model/blob/master/traffic_accident_time_series_analysis.ipynb)           --> trình bày quá trình phân tích chuỗi thời gian

├── traffic_accident_analysis_presentation [Here](https://github.com/VoTuan0512/traffic-accident-prophet-model/blob/master/traffic_accident_analysis_presentation.pdf)           --> trình bày kết quả phân tích 

└── README.md                                                                                                                                                                    --> Mô tả dự án

**🛠 Công cụ và phương pháp**

Công cụ
- SQL: truy vấn dữ liệu gồm các kỹ thuật truy vấn như: Conditional & Logical (case when), CTE, Window Functions , Transformation (cast, round),...
- Excel: trực quan hóa biểu đồ dùng cho kết quả phân tích
- Python:  để xử lý dữ liệu và trực quan hóa bằng một số thư viện như: Prophet cho việc phân tích chuỗi thời gian và numpy , statsmodel , scipy , matplotlib ,... cho việc sử dụng các phương pháp thống kê và trực quan hóa kết quả

Phương pháp

- Tách chuỗi thời gian thành các phần Xu hướng (trend) , Chu kỳ (Season) và Phần dư (Residual) để hiểu rõ điều gì đang ảnh hưởng đến dữ liệu

Nội dung được trình bày bằng tiếng Việt, hướng tới đối tượng là cộng đồng và cơ quan chức năng trong nước.

**📌 Một số phát hiện chính**

Tai nạn giao thông có xu hướng giảm theo thời gian, nhưng mức độ giảm trong xu hướng đang yếu dần về cuối năm 
--> Điều tiết giao thông về cuối năm vẫn còn nhiều bất cập.

![image](https://github.com/user-attachments/assets/590f98f5-970b-44a1-8ed1-2d4c3a0f6d3e)




Các yếu tố tự nhiên (mưa lớn, bão) không gây ra nhiều vụ tai nạn và thương vong so với yếu tố con người nhưng đều gây ra tai nạn quanh năm đòi hỏi hệ thống cảnh báo và cơ sở hạ tầng tốt hơn.

![image](https://github.com/user-attachments/assets/f0d7f17f-dc4a-47d0-abb4-310bbe5183cb)




**✍️ Tác giả**
Phân tích và thực hiện bởi Nguyễn Võ Anh Tuấn, một người yêu thích lĩnh vực phân tích dữ liệu và mong muốn chia sẽ những phân tích và đề suất cơ bản để góp phẩn cải thiện an toàn giao thông tại Việt Nam.
