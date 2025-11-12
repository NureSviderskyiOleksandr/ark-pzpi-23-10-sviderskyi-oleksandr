# --- В.1 Метод "Encapsulate Field" – "До" рефакторингу ---

# Поля @status та @items є публічними для запису
class Order
  attr_accessor :status, :items

  def initialize
    @status = :pending
    @items = []
  end

  def total_price
    @items.sum(&:price)
  end
end

class PaymentService
  def process_payment(order)
    # ... логіка оплати ...
    
    # ПОГАНО: Зовнішній клас напряму змінює стан замовлення.
    # Що як ми забудемо зняти товари зі складу?
    order.status = :paid
  end
end

# --- Використання (До) ---
order = Order.new

# ПОГАНО: Можна напряму додати товар, оминувши будь-які перевірки
# (наприклад, перевірку наявності на складі).
order.items << Product.new(name: "Test", price: 100)
order.items << nil # Також можна додати невалідні дані

# ПОГАНО: Можна встановити будь-який неіснуючий статус.
order.status = :shipped_yesterday # Невалідний статус

###########################################################################################################################

# --- В.2 Метод "Encapsulate Field" – "Після" рефакторингу ---

class OrderRefactored
  # Дозволяємо читати стан, але не змінювати напряму
  attr_reader :status, :items

  def initialize
    @status = :pending
    @items = []
  end

  def total_price
    @items.sum(&:price)
  end

  # ДОБРЕ: Спеціалізований метод для додавання
  def add_item(product)
    raise "Product cannot be nil" if product.nil?
    # Можна додати логіку: check_stock(product)
    @items << product
    puts "#{product.name} додано до замовлення."
  end

  # ДОБРЕ: Методи, що контролюють зміну стану
  def pay!
    # Тут може бути логіка перевірки
    @status = :paid
    puts "Замовлення оплачено."
    # send_invoice
  end

  def ship!
    if @status == :paid
      @status = :shipped
      puts "Замовлення відправлено."
      # reduce_stock
    else
      puts "Неможливо відправити неоплачене замовлення."
    end
  end
end

# --- Використання (Після) ---
order_r = OrderRefactored.new
product = Product.new(name: "Ноутбук", price: 1500)

order_r.add_item(product)
# order_r.add_item(nil) # => "Product cannot be nil" (RuntimeError)

# order_r.status = :paid # => NoMethodError: private method `status='
order_r.ship! # => "Неможливо відправити неоплачене замовлення."
order_r.pay!  # => "Замовлення оплачено."
order_r.ship! # => "Замовлення відправлено."

###########################################################################################################################

# --- В.3 Метод "Remove Control Flag" – "До" рефакторингу ---

class TransactionProcessor
  def process_batch(transactions)
    found_error = false # Керуючий прапор
    error_message = nil

    transactions.each do |tx|
      # Логіка ускладнюється через перевірку прапора
      if !found_error
        if tx.amount > tx.user.balance
          # Встановлюємо прапор
          found_error = true
          error_message = "Помилка (ID: #{tx.id}): Недостатньо коштів."
        elsif tx.amount <= 0
          found_error = true
          error_message = "Помилка (ID: #{tx.id}): Некоректна сума."
        else
          # Обробка валідної транзакції
          puts "Обробка транзакції #{tx.id}..."
          tx.execute
        end
      end
    end

    if found_error
      puts "Обробку зупинено. #{error_message}"
      return false
    else
      puts "Усі транзакції успішно оброблено."
      return true
    end
  end
end

###########################################################################################################################

# --- В.4 Метод "Remove Control Flag" – "Після" рефакторингу ---

class TransactionProcessorRefactored
  def process_batch(transactions)
    # Використовуємо .each, щоб мати змогу вийти з методу через `return`
    transactions.each do |tx|
      if tx.amount > tx.user.balance
        # Негайний вихід з методу
        puts "Обробку зупинено. Помилка (ID: #{tx.id}): Недостатньо коштів."
        return false
      end

      if tx.amount <= 0
        puts "Обробку зупинено. Помилка (ID: #{tx.id}): Некоректна сума."
        return false
      end

      # Цей код виконається, тільки якщо всі перевірки пройдені
      puts "Обробка транзакції #{tx.id}..."
      tx.execute
    end

    # Якщо цикл завершився без `return false`, значить все добре
    puts "Усі транзакції успішно оброблено."
    return true
  end
end

###########################################################################################################################

# --- В.5 Метод "Replace Array with Object" – "До" рефакторингу ---

class UserReport
  # Метод отримує "сирі" дані, наприклад, з DB-запиту
  def generate_activity_report(raw_data)
    puts "Звіт про активність користувачів:"
    puts "-----------------------------------"
    
    active_users = raw_data.select do |user_array|
      # ПОГАНО: магічний індекс [3] (last_login_date)
      # Ми не знаємо, що таке [3] без документації.
      user_array[3] > (Time.now - 30 * 86400) # 30 днів
    end

    active_users.each do |user_array|
      # ПОГАНО: магічні індекси [1] (username) та [2] (email)
      puts "Активний користувач: #{user_array[1]} (Email: #{user_array[2]})"
    end
    
    puts "-----------------------------------"
    puts "Всього активних: #{active_users.count}"
  end
end

# --- Використання (До) ---
# Дані, що прийшли з бази даних у вигляді масиву масивів
db_data = [
  [1, "admin", "admin@example.com", Time.now - 86400 * 5],
  [2, "alice", "alice@example.com", Time.now - 86400 * 40],
  [3, "bob", "bob@example.com", Time.now - 86400 * 10]
]

report = UserReport.new
report.generate_activity_report(db_data)

###########################################################################################################################

# --- В.6 Метод "Replace Array with Object" – "Після" рефакторингу ---

# ДОБРЕ: Створюємо клас або Struct для представлення даних.
# Struct ідеально підходить для таких простих "контейнерів даних".
UserRecord = Struct.new(:id, :username, :email, :last_login_date)

class UserReportRefactored
  def generate_activity_report(raw_data)
    # 1. Перетворюємо масиви на об'єкти
    user_records = raw_data.map do |row|
      UserRecord.new(row[0], row[1], row[2], row[3])
    end

    puts "Звіт про активність користувачів:"
    puts "-----------------------------------"

    # ДОБРЕ: Код читається як звичайна англійська
    active_users = user_records.select do |user|
      user.last_login_date > (Time.now - 30 * 86400) # 30 днів
    end

    active_users.each do |user|
      # ДОБРЕ: Ніяких індексів, тільки осмислені імена полів
      puts "Активний користувач: #{user.username} (Email: #{user.email})"
    end
    
    puts "-----------------------------------"
    puts "Всього активних: #{active_users.count}"
  end
end

# --- Використання (Після) ---
# Дані ті самі
db_data = [
  [1, "admin", "admin@example.com", Time.now - 86400 * 5],
  [2, "alice", "alice@example.com", Time.now - 86400 * 40],
  [3, "bob", "bob@example.com", Time.now - 86400 * 10]
]

report_r = UserReportRefactored.new
report_r.generate_activity_report(db_data)
