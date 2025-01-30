import bcrypt

hashed_password = b"$2a$10$juNO2sr5kpTe8L53/Cg7LuH.YonQyBEH5asJm3iP5OwnCxFhust4m"
password_to_check = "nylabank_!@#$"

if bcrypt.checkpw(password_to_check.encode(), hashed_password):
    print("Password matches!")
else:
    print("Password does not match.")
