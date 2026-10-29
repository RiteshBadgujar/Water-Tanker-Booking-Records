<%@ page import="java.sql.*" %>
<%@ page import="java.time.LocalDate" %>

<%
    String name = request.getParameter("name");
    String area = request.getParameter("area");
    String bookingDate = request.getParameter("booking_date");
    String size = request.getParameter("size");

    String url = "jdbc:mysql://localhost:3306/watertankdb1";
    String dbUser = "root";
    String dbPass = "root";

    String message = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");

        try (Connection con =
                DriverManager.getConnection(url, dbUser, dbPass)) {

            if (name != null && area != null &&
                bookingDate != null && size != null) {

                if (name.trim().isEmpty() ||
                    area.trim().isEmpty() ||
                    name.length() > 40 || area.length() > 30 ||
                    !size.matches("5000 L|10000 L|12000 L") ||
                    LocalDate.parse(bookingDate).isBefore(LocalDate.now())) {

                    throw new IllegalArgumentException(
                        "Invalid booking details or booking date.");
                }

                String sql = "INSERT INTO  tank " +
                    "(name, area, booking_date, size) VALUES (?, ?, ?, ?)";

                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, name.trim());
                    ps.setString(2, area.trim());
                    ps.setDate(3, Date.valueOf(bookingDate));
                    ps.setString(4, size);

                    ps.executeUpdate();
                }

                message = "Booking saved successfully!";
            }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Booking Results</title>

    <style>
        body {
            font-family: Arial, sans-serif;
            background: #edf2f3;
            padding: 25px;
        }

        .container {
            max-width: 900px;
            margin: auto;
            background: white;
            padding: 25px;
            border-top: 5px solid #287271;
            box-shadow: 0 3px 12px #c7d0d0;
        }

        h2 {
            color: #245b59;
            text-align: center;
        }

        .message {
            background: #e4f1e8;
            color: #245b35;
            padding: 12px;
            margin-bottom: 18px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        th, td {
            border: 1px solid #c8d1d1;
            padding: 11px;
            text-align: left;
        }

        th {
            background: #287271;
            color: white;
        }

        tr:nth-child(even) {
            background: #f2f6f6;
        }

        a {
            display: inline-block;
            margin-top: 20px;
            background: #287271;
            color: white;
            padding: 10px 16px;
            text-decoration: none;
        }
    </style>
</head>

<body>
<div class="container">

    <h2>Water Tanker Booking Records</h2>

    <div class="message"><%= message %></div>

    <table>
        <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Area</th>
            <th>Booking Date</th>
            <th>Tanker Size</th>
        </tr>

        <%
            String query = "SELECT * FROM tank " +
                        "ORDER BY id DESC LIMIT 5";

            try (PreparedStatement ps = con.prepareStatement(query);
                ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
        %>
        <tr>
            <td><%= rs.getInt("id") %></td>
            <td><%= rs.getString("name") %></td>
            <td><%= rs.getString("area") %></td>
            <td><%= rs.getDate("booking_date") %></td>
            <td><%= rs.getString("size") %></td>
        </tr>
        <%
                }
            }
        %>
    </table>

    <a href="index.html">New Booking</a>

</div>
</body>
</html>

<%
        }
    } catch (Exception e) {
        out.println("<h3>Booking Error: " +
            e.getMessage().replace("&", "&amp;")
                        .replace("<", "&lt;")
                        .replace(">", "&gt;") +
            "</h3>");
    }
%>