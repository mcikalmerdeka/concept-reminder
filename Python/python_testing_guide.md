# Python Testing Guide

Testing is the practice of verifying that your code behaves as expected. It catches bugs before users do, prevents regressions when you change existing code, and — when done well — acts as living documentation for how your system is supposed to work.

---

## Why Testing Matters

| Without Tests | With Tests |
|---|---|
| Manual re-checking after every change | Automated safety net on every change |
| Bugs discovered in production | Bugs caught before deployment |
| Fear of refactoring | Confidence to refactor |
| Unclear expected behavior | Tests document intent |

---

## The Testing Pyramid

```
        /\
       /  \          E2E / Functional Tests
      /    \          (few, slow, expensive)
     /------\
    /        \       Integration Tests
   /          \       (moderate number)
  /------------\
 /              \    Unit Tests
/________________\   (many, fast, cheap)
```

A healthy test suite has many unit tests at the base, fewer integration tests in the middle, and a small number of end-to-end or functional tests at the top.

---

## 1. Unit Testing

Tests a **single function or class in isolation**, with no dependency on external systems (databases, APIs, file systems). These are the fastest tests to write and run.

### The Code Under Test

```python
# math_operations.py

def add(a, b):
    return a + b

def subtract(a, b):
    return a - b

def divide(a, b):
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b
```

### With `unittest`

```python
# test_math_unittest.py
import unittest
from math_operations import add, subtract, divide

class TestMathOperations(unittest.TestCase):

    def test_add_positive_numbers(self):
        self.assertEqual(add(2, 3), 5)

    def test_add_negative_numbers(self):
        self.assertEqual(add(-1, -1), -2)

    def test_subtract(self):
        self.assertEqual(subtract(10, 4), 6)

    def test_divide_normal(self):
        self.assertEqual(divide(10, 2), 5.0)

    def test_divide_by_zero_raises_error(self):
        with self.assertRaises(ValueError):
            divide(10, 0)

if __name__ == "__main__":
    unittest.main()
```

### With `pytest`

```python
# test_math_pytest.py
import pytest
from math_operations import add, subtract, divide

def test_add_positive_numbers():
    assert add(2, 3) == 5

def test_add_negative_numbers():
    assert add(-1, -1) == -2

def test_subtract():
    assert subtract(10, 4) == 6

def test_divide_normal():
    assert divide(10, 2) == 5.0

def test_divide_by_zero_raises_error():
    with pytest.raises(ValueError):
        divide(10, 0)

# pytest bonus: parametrize lets you test multiple inputs without repeating code
@pytest.mark.parametrize("a, b, expected", [
    (2, 3, 5),
    (-1, 1, 0),
    (0, 0, 0),
    (100, -50, 50),
])
def test_add_parametrized(a, b, expected):
    assert add(a, b) == expected
```

> **When to use:** Any time you write a pure function or a class method that has clear inputs and outputs.

---

## 2. Integration Testing

Tests how **multiple components work together**. Unlike unit tests, integration tests allow real interactions between modules — including databases, file systems, or internal services. The goal is to catch communication errors between components.

### The Code Under Test

```python
# user_service.py

DATABASE = {}

def save_user(user_id: str, name: str):
    """Simulates a database write."""
    DATABASE[user_id] = name

def get_user(user_id: str):
    """Simulates a database read."""
    return DATABASE.get(user_id)

def register_user(user_id: str, name: str) -> str:
    """Orchestrates validation + persistence."""
    if not name or not name.strip():
        return "Error: Invalid name"
    if get_user(user_id):
        return "Error: User already exists"
    save_user(user_id, name)
    return "Success"
```

### With `unittest`

```python
# test_user_service_unittest.py
import unittest
from user_service import register_user, get_user, DATABASE

class TestUserIntegration(unittest.TestCase):

    def setUp(self):
        """Runs before each test — reset shared state."""
        DATABASE.clear()

    def test_register_new_user(self):
        result = register_user("u001", "Alice")
        self.assertEqual(result, "Success")
        # Verify the data actually made it into the "database"
        self.assertEqual(get_user("u001"), "Alice")

    def test_register_empty_name(self):
        result = register_user("u002", "")
        self.assertEqual(result, "Error: Invalid name")
        self.assertIsNone(get_user("u002"))

    def test_register_duplicate_user(self):
        register_user("u003", "Bob")
        result = register_user("u003", "Bob Again")
        self.assertEqual(result, "Error: User already exists")

if __name__ == "__main__":
    unittest.main()
```

### With `pytest`

```python
# test_user_service_pytest.py
import pytest
from user_service import register_user, get_user, DATABASE

@pytest.fixture(autouse=True)
def clear_database():
    """Fixture: auto-runs before each test to reset state."""
    DATABASE.clear()
    yield  # test runs here
    DATABASE.clear()  # teardown after test

def test_register_new_user():
    result = register_user("u001", "Alice")
    assert result == "Success"
    assert get_user("u001") == "Alice"

def test_register_empty_name():
    result = register_user("u002", "")
    assert result == "Error: Invalid name"
    assert get_user("u002") is None

def test_register_duplicate_user():
    register_user("u003", "Bob")
    result = register_user("u003", "Bob Again")
    assert result == "Error: User already exists"
```

> **When to use:** When you want to verify that two or more modules behave correctly together — especially database reads/writes, service-to-service calls, or file I/O.

---

## 3. Functional Testing (Black-Box Testing)

Tests software **against business requirements**, not internal implementation. You treat the system as a black box: given this input, the output must satisfy the business rule. You don't care how it works internally.

### The Code Under Test

```python
# ecommerce.py

VALID_COUPONS = {
    "SAVE10": 0.10,
    "SAVE20": 0.20,
    "HALFOFF": 0.50,
}

def calculate_final_price(cart_total: float, coupon_code: str = None) -> float:
    """
    Business rules:
    - Valid coupons apply their discount percentage
    - Invalid or missing coupons: no discount
    - Price cannot go below 0
    """
    if coupon_code and coupon_code in VALID_COUPONS:
        discount = VALID_COUPONS[coupon_code]
        cart_total = cart_total * (1 - discount)
    return max(cart_total, 0.0)
```

### With `unittest`

```python
# test_ecommerce_unittest.py
import unittest
from ecommerce import calculate_final_price

class TestCheckoutFunctional(unittest.TestCase):

    # Business rule: SAVE10 gives exactly 10% off
    def test_save10_coupon(self):
        self.assertEqual(calculate_final_price(100, "SAVE10"), 90.0)

    # Business rule: SAVE20 gives exactly 20% off
    def test_save20_coupon(self):
        self.assertEqual(calculate_final_price(100, "SAVE20"), 80.0)

    # Business rule: HALFOFF gives 50% off
    def test_halfoff_coupon(self):
        self.assertEqual(calculate_final_price(200, "HALFOFF"), 100.0)

    # Business rule: invalid coupon = no discount
    def test_invalid_coupon_no_discount(self):
        self.assertEqual(calculate_final_price(100, "FAKECODE"), 100.0)

    # Business rule: no coupon = no discount
    def test_no_coupon(self):
        self.assertEqual(calculate_final_price(100), 100.0)

    # Edge case from business rules: price cannot go below 0
    def test_price_never_negative(self):
        self.assertGreaterEqual(calculate_final_price(0, "SAVE10"), 0.0)

if __name__ == "__main__":
    unittest.main()
```

### With `pytest`

```python
# test_ecommerce_pytest.py
import pytest
from ecommerce import calculate_final_price

# Parametrize maps directly to business requirement rows — very readable
@pytest.mark.parametrize("cart_total, coupon, expected", [
    (100.0, "SAVE10",  90.0),   # 10% off
    (100.0, "SAVE20",  80.0),   # 20% off
    (200.0, "HALFOFF", 100.0),  # 50% off
    (100.0, "FAKECODE", 100.0), # invalid coupon — no discount
    (100.0, None,       100.0), # no coupon — no discount
    (0.0,   "SAVE10",   0.0),   # edge: zero cart
])
def test_checkout_pricing(cart_total, coupon, expected):
    assert calculate_final_price(cart_total, coupon) == expected

def test_price_never_negative():
    assert calculate_final_price(0, "SAVE10") >= 0.0
```

> **When to use:** Validating that your application satisfies business requirements, acceptance criteria, or user stories. Great for testing public-facing APIs or entire service flows.

---

## 4. Mocking External Dependencies

Both unit and integration tests sometimes need to **mock** external systems (HTTP APIs, databases, email services) so your test doesn't depend on network availability or real data.

### The Code Under Test

```python
# weather_service.py
import requests

def get_temperature(city: str) -> str:
    response = requests.get(f"https://api.weather.com/v1/{city}")
    data = response.json()
    return f"{data['temp']}°C in {city}"
```

### With `unittest` (using `unittest.mock`)

```python
# test_weather_unittest.py
import unittest
from unittest.mock import patch, MagicMock
from weather_service import get_temperature

class TestWeatherService(unittest.TestCase):

    @patch("weather_service.requests.get")
    def test_get_temperature(self, mock_get):
        # Arrange: fake the HTTP response
        mock_response = MagicMock()
        mock_response.json.return_value = {"temp": 28}
        mock_get.return_value = mock_response

        # Act
        result = get_temperature("Jakarta")

        # Assert
        self.assertEqual(result, "28°C in Jakarta")
        mock_get.assert_called_once_with("https://api.weather.com/v1/Jakarta")

if __name__ == "__main__":
    unittest.main()
```

### With `pytest` (using `pytest-mock`)

```bash
pip install pytest-mock
```

```python
# test_weather_pytest.py
from weather_service import get_temperature

def test_get_temperature(mocker):
    # Arrange: mock the HTTP call
    mock_response = mocker.MagicMock()
    mock_response.json.return_value = {"temp": 28}
    mocker.patch("weather_service.requests.get", return_value=mock_response)

    # Act + Assert
    result = get_temperature("Jakarta")
    assert result == "28°C in Jakarta"
```

---

## `unittest` vs `pytest` — Quick Comparison

| Feature | `unittest` | `pytest` |
|---|---|---|
| Availability | Built into Python stdlib | Needs `pip install pytest` |
| Boilerplate | Class + method required | Plain functions work |
| Assertions | `self.assertEqual(a, b)` | Plain `assert a == b` |
| Parametrize | `@parameterized` (external lib) | `@pytest.mark.parametrize` (built-in) |
| Fixtures | `setUp` / `tearDown` | `@pytest.fixture` (more flexible) |
| Output | Basic | Detailed diffs, colors, plugins |
| Mocking | `unittest.mock` (built-in) | `pytest-mock` (wrapper around unittest.mock) |
| Plugin ecosystem | Minimal | Rich (pytest-cov, pytest-asyncio, etc.) |

**Rule of thumb:** Use `pytest` for new projects. Use `unittest` if you're working in a codebase that already uses it, or if you can't install third-party packages.

---

## Running Your Tests

```bash
# unittest — discover and run all test files matching test_*.py
python -m unittest discover

# unittest — run a specific file
python -m unittest test_math_unittest.py

# pytest — discover and run everything
pytest

# pytest — run a specific file
pytest test_math_pytest.py

# pytest — run with verbose output
pytest -v

# pytest — run a specific test function
pytest test_math_pytest.py::test_add_positive_numbers

# pytest — run with coverage report (requires pytest-cov)
pip install pytest-cov
pytest --cov=. --cov-report=term-missing
```

---

## Project Structure Convention

```
your_project/
├── src/
│   ├── math_operations.py
│   ├── user_service.py
│   └── ecommerce.py
├── tests/
│   ├── unit/
│   │   └── test_math.py
│   ├── integration/
│   │   └── test_user_service.py
│   └── functional/
│       └── test_ecommerce.py
├── requirements.txt
└── pytest.ini          # optional pytest config
```

`pytest.ini` example:

```ini
[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
```
