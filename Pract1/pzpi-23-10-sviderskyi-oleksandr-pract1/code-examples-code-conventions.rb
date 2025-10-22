# ===============================================================
# В.1 Читабельний стиль коду
# ===============================================================

# Погано
def hi(name) puts"Hello,#{name}!"end

# Добре
def hi(name)
  puts "Hello, #{name}!"
end

# ===============================================================
# В.2 Іменування: snake_case для змінних і методів, CamelCase для класів
# ===============================================================

# Погано
userName = "Olena"
def PrintMessage; end
class userprofile; end

# Добре
user_name = "Olena"

def print_message
  puts "Hello!"
end

class UserProfile
end

# ===============================================================
# В.3 Уникайте зайвого коду
# ===============================================================

# Погано
if is_admin == true
  puts "Welcome, admin!"
end

# Добре
puts "Welcome, admin!" if is_admin

# ===============================================================
# В.4 Використовуйте символи замість рядків як ключі
# ===============================================================

# Погано
user = { "name" => "Alex", "age" => 19 }

# Добре
user = { name: "Alex", age: 19 }

# Пояснення:
# :name та :age — це символи, вони займають менше пам'яті та зручніші як ключі хешів.

# ===============================================================
# В.5 Відступи та форматування (2 пробіли, не табуляція)
# ===============================================================

# Погано
def greet(name)
if name
puts "Hi, #{name}!"
else
puts "Hi, stranger!"
end
end

# Добре
def greet(name)
  if name
    puts "Hi, #{name}!"
  else
    puts "Hi, stranger!"
  end
end

# ===============================================================
# В.6 DRY (Don't Repeat Yourself) — не повторюй себе
# ===============================================================

# Погано
puts "Hello, Dmytro!"
puts "Hello, Olena!"
puts "Hello, Oksana!"

# Добре
def greet(name)
  puts "Hello, #{name}!"
end

["Dmytro", "Olena", "Oksana"].each { |name| greet(name) }

# ===============================================================
# В.7 Використовуйте each, map, select замість for
# ===============================================================

# Погано
for i in 0..4
  puts i
end

# Добре
(0..4).each { |i| puts i }

# ===============================================================
# В.8 Коментарі мають пояснювати "чому", а не "що"
# ===============================================================

# Погано
# Виводимо привітання користувачу
puts "Hello, #{user.name}!"

# Добре
# Зберігаємо користувача в базі лише якщо він валідний
save_user(user) if user.valid?

# ===============================================================
# В.9 Обробка помилок через begin...rescue
# ===============================================================

def risky_operation
  raise "Test error" if rand > 0.5
  puts "Успіх!"
end

begin
  risky_operation
rescue StandardError => e
  puts "Сталася помилка: #{e.message}"
end

# ===============================================================
# В.10 Приклад узагальнення (завершення презентації)
# ===============================================================
# Клас користувача
class User
  attr_reader :name, :age, :role

  def initialize(name:, age:, role:)
    @name = name
    @age = age
    @role = role
  end

  # Метод перевіряє, чи є користувач адміністратором
  def admin?
    role == :admin
  end

  # Привітання користувача
  def greet
    puts "Hello, #{name}! (#{role.capitalize})"
  end
end

# Константа — приклад уникнення "магічних чисел"
MIN_ADULT_AGE = 18

# Створюємо список користувачів (ключі як символи)
users = [
  User.new(name: "Olena", age: 25, role: :admin),
  User.new(name: "Dmytro", age: 17, role: :guest),
  User.new(name: "Oksana", age: 30, role: :member)
]

# Функція для перевірки віку користувача
def adult?(user)
  user.age >= MIN_ADULT_AGE
end

# Вивід користувачів, які є повнолітніми
puts "\n=== Повнолітні користувачі ==="
users.select { |u| adult?(u) }.each(&:greet)

# Використання блоку map для отримання імен користувачів
user_names = users.map(&:name)
puts "\nУсі користувачі: #{user_names.join(', ')}"

# Демонстрація обробки помилок
def risky_division(a, b)
  raise ZeroDivisionError, "Ділення на нуль!" if b.zero?
  a / b
end

begin
  puts "\nРезультат ділення: #{risky_division(10, 0)}"
rescue StandardError => e
  puts "⚠️  Помилка під час виконання: #{e.message}"
end

