// employee-csharp.cs
// Complete C# console program for "Visual Studio and C# Database:
// Create a Database, Connect and Read Employee Data" (Sir Database).
// Save this file as Program.cs in a Console App project named EmployeeApp.
// It uses System.Data.SqlClient. On .NET Core / .NET 5 and later, the modern
// equivalent is the Microsoft.Data.SqlClient NuGet package; the code works
// the same with that namespace — only the using directive at the top changes.
// Target: .NET (any version with a Console App template). No extra setup
// is needed apart from SQL Server LocalDB, which comes with Visual Studio.

using System;
using System.Data.SqlClient;

class Program
{
    static void Main()
    {
        string masterConnectionString = @"Server=(localdb)\MSSQLLocalDB;Database=master;Trusted_Connection=True;";
        string connectionString = @"Server=(localdb)\MSSQLLocalDB;Database=CompanyDB;Trusted_Connection=True;";

        EnsureDatabase(masterConnectionString);

        using (SqlConnection connection = new SqlConnection(connectionString))
        {
            connection.Open();

            CreateTables(connection);
            InsertDepartments(connection);
            InsertEmployees(connection);
            UpdateHassanSalary(connection);
            ReadEmployees(connection);
            PrintEmployeeCount(connection);
        }

        Console.WriteLine("Done. Press any key to exit.");
        Console.ReadKey();
    }

    static void EnsureDatabase(string masterConnectionString)
    {
        using (SqlConnection connection = new SqlConnection(masterConnectionString))
        {
            connection.Open();
            string sql = "IF DB_ID('CompanyDB') IS NULL CREATE DATABASE CompanyDB;";
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.ExecuteNonQuery();
            }
        }
    }

    static void CreateTables(SqlConnection connection)
    {
        string departmentsSql = @"IF OBJECT_ID('dbo.Departments', 'U') IS NULL
CREATE TABLE Departments (
    DepartmentId INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName NVARCHAR(50) NOT NULL UNIQUE,
    Location NVARCHAR(100)
);";

        string employeesSql = @"IF OBJECT_ID('dbo.Employees', 'U') IS NULL
CREATE TABLE Employees (
    EmployeeId INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    DepartmentId INT FOREIGN KEY REFERENCES Departments(DepartmentId),
    Salary DECIMAL(10,2),
    HireDate DATE
);";

        using (SqlCommand command = new SqlCommand(departmentsSql, connection))
        {
            command.ExecuteNonQuery();
        }

        using (SqlCommand command = new SqlCommand(employeesSql, connection))
        {
            command.ExecuteNonQuery();
        }
    }

    static void InsertDepartments(SqlConnection connection)
    {
        string countSql = "SELECT COUNT(*) FROM Departments;";
        using (SqlCommand countCommand = new SqlCommand(countSql, connection))
        {
            int count = (int)countCommand.ExecuteScalar();
            if (count > 0)
            {
                return;
            }
        }

        string sql = "INSERT INTO Departments (DepartmentName) VALUES (@Name);";
        string[] departments = { "HR", "IT", "Sales", "Finance" };

        using (SqlCommand command = new SqlCommand(sql, connection))
        {
            foreach (string department in departments)
            {
                command.Parameters.Clear();
                command.Parameters.AddWithValue("@Name", department);
                command.ExecuteNonQuery();
            }
        }
    }

    static void InsertEmployees(SqlConnection connection)
    {
        string countSql = "SELECT COUNT(*) FROM Employees;";
        using (SqlCommand countCommand = new SqlCommand(countSql, connection))
        {
            int count = (int)countCommand.ExecuteScalar();
            if (count > 0)
            {
                return;
            }
        }

        string sql = "INSERT INTO Employees (FirstName, LastName, Email, DepartmentId, Salary, HireDate) " +
                     "VALUES (@FirstName, @LastName, @Email, @DepartmentId, @Salary, @HireDate);";

        var employees = new (string FirstName, string LastName, string Email, int DepartmentId, decimal Salary, DateTime HireDate)[]
        {
            ("Ali", "Khan", "ali.khan@company.com", 2, 85000m, new DateTime(2022, 3, 15)),
            ("Sara", "Ahmed", "sara.ahmed@company.com", 1, 72000m, new DateTime(2021, 6, 1)),
            ("Usman", "Malik", "usman.malik@company.com", 2, 92000m, new DateTime(2020, 11, 20)),
            ("Fatima", "Noor", "fatima.noor@company.com", 3, 68000m, new DateTime(2023, 1, 10)),
            ("Hassan", "Raza", "hassan.raza@company.com", 3, 71000m, new DateTime(2022, 8, 5)),
            ("Ayesha", "Siddiqui", "ayesha.siddiqui@company.com", 4, 88000m, new DateTime(2019, 4, 12)),
            ("Bilal", "Hussain", "bilal.hussain@company.com", 2, 79000m, new DateTime(2023, 5, 22)),
            ("Maryam", "Tariq", "maryam.tariq@company.com", 1, 65000m, new DateTime(2024, 2, 1))
        };

        using (SqlCommand command = new SqlCommand(sql, connection))
        {
            foreach (var employee in employees)
            {
                command.Parameters.Clear();
                command.Parameters.AddWithValue("@FirstName", employee.FirstName);
                command.Parameters.AddWithValue("@LastName", employee.LastName);
                command.Parameters.AddWithValue("@Email", employee.Email);
                command.Parameters.AddWithValue("@DepartmentId", employee.DepartmentId);
                command.Parameters.AddWithValue("@Salary", employee.Salary);
                command.Parameters.AddWithValue("@HireDate", employee.HireDate);
                command.ExecuteNonQuery();
            }
        }
    }

    static void UpdateHassanSalary(SqlConnection connection)
    {
        string sql = "UPDATE Employees SET Salary = @Salary WHERE FirstName = @FirstName AND LastName = @LastName;";
        using (SqlCommand command = new SqlCommand(sql, connection))
        {
            command.Parameters.AddWithValue("@Salary", 73000m);
            command.Parameters.AddWithValue("@FirstName", "Hassan");
            command.Parameters.AddWithValue("@LastName", "Raza");
            int rows = command.ExecuteNonQuery();
            Console.WriteLine("Updated Hassan Raza's salary. Rows affected: " + rows);
        }
    }

    static void ReadEmployees(SqlConnection connection)
    {
        string sql = "SELECT e.EmployeeId, e.FirstName, e.LastName, e.Email, d.DepartmentName, e.Salary, e.HireDate " +
                     "FROM Employees e INNER JOIN Departments d ON e.DepartmentId = d.DepartmentId " +
                     "ORDER BY e.EmployeeId;";

        Console.WriteLine("ID | Name | Email | Department | Salary | HireDate");

        using (SqlCommand command = new SqlCommand(sql, connection))
        {
            using (SqlDataReader reader = command.ExecuteReader())
            {
                while (reader.Read())
                {
                    int id = reader.GetInt32(0);
                    string firstName = reader.GetString(1);
                    string lastName = reader.GetString(2);
                    string email = reader.GetString(3);
                    string department = reader.GetString(4);
                    decimal salary = reader.GetDecimal(5);
                    DateTime hireDate = reader.GetDateTime(6);
                    Console.WriteLine($"{id} | {firstName} {lastName} | {email} | {department} | {salary:0.00} | {hireDate:yyyy-MM-dd}");
                }
            }
        }
    }

    static void PrintEmployeeCount(SqlConnection connection)
    {
        string sql = "SELECT COUNT(*) FROM Employees;";
        using (SqlCommand command = new SqlCommand(sql, connection))
        {
            int count = (int)command.ExecuteScalar();
            Console.WriteLine("Total employees: " + count);
        }
    }

    // Example only — this method is never called, so no employee is deleted.
    // It shows the DELETE pattern: delete one row by its id, with a parameter.
    static void DeleteEmployeeExample(SqlConnection connection)
    {
        string sql = "DELETE FROM Employees WHERE EmployeeId = @Id;";
        using (SqlCommand command = new SqlCommand(sql, connection))
        {
            command.Parameters.AddWithValue("@Id", 8);
            int rows = command.ExecuteNonQuery();
            Console.WriteLine("Deleted employees: " + rows);
        }
    }
}
