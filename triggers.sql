-- Задание 1
CREATE OR REPLACE FUNCTION process_check_changes() RETURNS TRIGGER
AS $emp_audit$
	begin
	if NEW."Дата поставки" IS NULL then 
			new."Дата поставки" = current_date ;
	end if;
	if new."Количество товара" < 0 then
		RAISE EXCEPTION 'Проверьте количество товара';
	elsif new."Цена единицы товара" <= 0 then
		RAISE EXCEPTION 'Проверьте цену товара';
	elsif current_date < new."Дата поставки" then
		RAISE EXCEPTION 'Проверьте дату поставки';
	elsif new."Остаток товара" > new."Количество товара" then
		RAISE EXCEPTION 'Проверьте остаток товара';
	elsif new."Остаток товара" < 0 then
		RAISE EXCEPTION 'Проверьте остаток товара';
	else 
		IF (TG_OP = 'UPDATE') then
			update "Поставки" set "Шифр поставки" = new."Шифр поставки", "Поставщик" = new."Поставщик", "Артикул товара" = new."Артикул товара", "Количество товара" = new."Количество товара", "Цена единицы товара" = new."Цена единицы товара", "Дата поставки" = new."Дата поставки", "Остаток товара" = new."Остаток товара" where "Шифр поставки" = new."Шифр поставки";
		ELSIF (TG_OP = 'INSERT') then
			insert into "Поставки" values (new."Шифр поставки", new."Поставщик", new."Артикул товара", new."Количество товара", new."Цена единицы товара", new."Дата поставки", new."Остаток товара");
		else
			RAISE EXCEPTION 'Проверьте правильность введенных данных';
		END IF;
	end if;
	RETURN NULL;
END;
$emp_audit$ LANGUAGE plpgsql;

CREATE TRIGGER check_changes
AFTER INSERT OR UPDATE 
ON "Поставки"
FOR EACH ROW
WHEN (pg_trigger_depth() = 0)
EXECUTE PROCEDURE process_check_changes();


-- Задание 2

-- Вспомогательная таблица:
CREATE TABLE IF NOT EXISTS "Изменения в таблице Товары"(
"Артикул товара" VARCHAR(8),
"Название товара" VARCHAR(30) not null,
"Категория товара" VARCHAR(40) references "Категории товара" ("Название"),
"Единица измерения" VARCHAR(20),
"Вес единицы товара" INT not null,
"Минимум запаса в магазине" INT not null,
"Пользователь" text not null,
"Операция" text not null,
"Номер действия" SERIAL PRIMARY KEY
);


CREATE OR REPLACE FUNCTION process_changes_items() RETURNS TRIGGER
AS $emp_audit$
	BEGIN
	IF (TG_OP = 'DELETE') THEN
		INSERT INTO "Изменения в таблице Товары" SELECT OLD.*, user, 'Delete';
	ELSIF (TG_OP = 'UPDATE') then
		INSERT INTO "Изменения в таблице Товары" SELECT OLD.*, user, 'Update';
	ELSIF (TG_OP = 'INSERT') then
		INSERT INTO "Изменения в таблице Товары" SELECT OLD.*, user, 'Insert';
	END IF;
	RETURN NULL;
END;
$emp_audit$ LANGUAGE plpgsql;

CREATE TRIGGER changes_items
AFTER INSERT OR UPDATE OR DELETE ON "Товары"
FOR EACH ROW EXECUTE FUNCTION process_changes_items();
