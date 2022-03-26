CREATE TABLE IF NOT EXISTS "Поставщики"(
"Идентификатор" NUMERIC(6) PRIMARY KEY,
"Поставщик" VARCHAR(50) not null,
"Адрес" VARCHAR(50) not null
);

CREATE TABLE IF NOT EXISTS "Категории товара"(
"Название" VARCHAR(40) PRIMARY key,
"Срок реализации, дней" INT not null 
);

CREATE TABLE IF NOT EXISTS "Товары"(
"Артикул товара" VARCHAR(8) PRIMARY KEY,
"Название товара" VARCHAR(30) not null,
"Категория товара" VARCHAR(40) references "Категории товара" ("Название"),
"Единица измерения" VARCHAR(20),
"Вес единицы товара" INT not null,
"Минимум запаса в магазине" INT not null
);

CREATE TABLE IF NOT EXISTS "Поставки"(
"Шифр поставки" NUMERIC(6) primary key,
"Поставщик" NUMERIC(6) references "Поставщики" ("Идентификатор") ,
"Артикул товара" VARCHAR(8) references "Товары" ("Артикул товара"),
"Количество товара" numeric(7,2) not null, check ("Количество товара" > 0),
"Цена единицы товара" numeric(8,2) check ("Цена единицы товара" > 0),
"Дата поставки" date not null,
"Остаток товара" numeric(7,2) check ("Остаток товара" >= 0), check ("Остаток товара" <= "Количество товара")
);
