-- ПОСТАВЩИКИ:

insert into "Поставщики" ("Идентификатор", "Поставщик", "Адрес") values (866713, 'TestName', 'TestAdress');

 Update "Поставщики" SET "Поставщик" = 'NewName' Where "Идентификатор" = 866713;

Delete from "Поставщики" where "Идентификатор" = 866713;

-- КАТЕГОРИИ ТОВАРА:

insert into "Категории товара" ("Название", "Срок реализации, дней") values ('Электроника', '365');

 Update "Категории товара" SET "Срок реализации, дней" = '100' Where "Название" = 'Электроника';

Delete from "Категории товара" where "Название" = 'Электроника';

-- ТОВАРЫ

insert into "Товары" values ('8fj29vc', 'Огурцы', 'Овощи', 'гр', 50, 10);

 Update "Товары" SET "Вес единицы товара" = 70 Where "Артикул товара" = '8fj29vc';

Delete from "Товары" where "Артикул товара" = '8fj29vc';

-- ПОСТАВКИ

insert into "Поставки" values ('73923', '3', '654bjh', 50, 150, '2022-01-31', 15);

Update "Поставки" SET "Поставщик" = 4 Where "Шифр поставки" = 73923;

Delete from "Поставки" where "Шифр поставки" = 73923; 
