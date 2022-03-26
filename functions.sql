-- Задание 1:
CREATE or replace FUNCTION new_price(price numeric(8,2), date_p date, realize int) returns numeric(8, 2)
AS $$
declare
	buf int := price * 0.2;
begin
	IF realize - (current_date - date_p) <= 3 
	then
		if buf <= 50 then
			price = price - buf;
		return price;
		else
			return price;
		end if;
	else
		return price;
	end if;
end;
$$ language plpgsql;

-- Задание 2:
CREATE or replace FUNCTION report (md int) returns TABLE("Текущая дата" date, "Категория" varchar(40), "Артикул товара" varchar(8), "Название товара" varchar(30), "Единица измерения" varchar(20), "Остаток" numeric(7, 2), "Старая цена" numeric(8, 2), "Новая цена" numeric(8,2)) as
$BODY$
BEGIN
    IF md = 0
    then
    	truncate "Изменение цены";
	END IF;
	INSERT INTO "Изменение цены" ("Текущая дата", "Категория", "Артикул товара", "Название товара", "Единица измерения", "Остаток", "Старая цена", "Новая цена")
	select current_date, t."Категория товара", t."Артикул товара", t."Название товара", t."Единица измерения", p."Остаток товара", p."Цена единицы товара", new_price(p."Цена единицы товара", p."Дата поставки", (select "Срок реализации, дней" from "Категории товара" as kat where kat."Название" = t."Категория товара"))
	from "Товары" as t inner join "Поставки" as p on t."Артикул товара" = p."Артикул товара";
	return query select current_date, t."Категория товара", t."Артикул товара", t."Название товара", t."Единица измерения", p."Остаток товара", p."Цена единицы товара", new_price(p."Цена единицы товара", p."Дата поставки", (select "Срок реализации, дней" from "Категории товара" as kat where kat."Название" = t."Категория товара"))
	from "Товары" as t inner join "Поставки" as p on t."Артикул товара" = p."Артикул товара";
END;
$BODY$
LANGUAGE plpgsql;


-- test: select * from report(0)
-- 	select * from report(1)

-- Номер 3
-- А)
-- Добавление:
CREATE or replace FUNCTION add_catofgoods (name_c varchar(40), time_c int) returns TABLE("Название" varchar(40), "Срок реализации, дней" int) as
$BODY$
begin
	if EXISTS(SELECT * FROM "Категории товара" WHERE "Категории товара"."Название" = name_c) then 
		RAISE EXCEPTION 'Такая категория уже существует!';
	else
		insert into "Категории товара" ("Название", "Срок реализации, дней") values (name_c, time_c);
		return query select name_c, time_c;
	end if; 
END;
$BODY$
LANGUAGE plpgsql;

-- Удаление:
CREATE or replace FUNCTION delete_catofgoods (name_c varchar(40)) returns varchar(30) as
$BODY$
begin
	if not EXISTS(SELECT * FROM "Категории товара" WHERE "Категории товара"."Название" = name_c) then 
		RAISE EXCEPTION 'Такой категории не существует!';
	else
		delete from "Категории товара" where "Категории товара"."Название" = name_c;
		return 'Успешно удалено!';
	end if; 
END;
$BODY$
LANGUAGE plpgsql;


-- Обновление: (кол-во дней)
CREATE or replace FUNCTION update_catofgoods (identificate varchar(40), time_c int) returns varchar(30) as
$BODY$
begin
	if not EXISTS(SELECT * FROM "Категории товара" WHERE "Категории товара"."Название" = identificate) then 
		RAISE EXCEPTION 'Такой категории не существует!';
	else
		update "Категории товара" set "Срок реализации, дней" = time_c where "Категории товара"."Название" = identificate;
		return 'Успешно обновлено!';
	end if; 
END;
$BODY$
LANGUAGE plpgsql;

-- Б)
-- Фильтрация "Общая стоимость остатков товаров": (вывод остатка по определенному имени)
CREATE or replace FUNCTION check_item (item_name varchar(40)) returns table("Категория товара" varchar(40), "Название товара" varchar(30), "Общая стоимость" numeric) as
$BODY$
begin
	if not EXISTS(select * from "Общая стоимость остатков товаров" where "Общая стоимость остатков товаров"."Название товара" = item_name) then 
		RAISE EXCEPTION 'Такого названия не существует в представлении!';
	else
		return query select * from "Общая стоимость остатков товаров" where "Общая стоимость остатков товаров"."Название товара" = item_name;
	end if;
END;
$BODY$
LANGUAGE plpgsql;

-- test: select * from check_item('Молоко');

-- Фильтрация "Остатки товаров":
CREATE or replace FUNCTION good_items () RETURNS table("Кол-во непросроченных товаров" numeric) as
$BODY$
begin
	return query select sum("Остатки товаров"."Остаток с неистекшим сроком") from "Остатки товаров";
END;
$BODY$
LANGUAGE plpgsql;

-- test: select * from good_items()

-- Фильтрация "Товары, поставленные в течение последних трех дней, остаток которых меньше 10% от первоначального количества":

CREATE or replace FUNCTION check_availability (item_name varchar(40)) RETURNS varchar(50) as
$BODY$
begin
	if EXISTS(select * from "Товары, 3 дня, 10 %" where "Товары, 3 дня, 10 %"."Название товара" = item_name) then 
		return 'Товар есть в представлении';
	else
		return 'Товара нет в представлении';
	end if;
END;
$BODY$
LANGUAGE plpgsql;

-- test: select check_availability('Хлеб')

