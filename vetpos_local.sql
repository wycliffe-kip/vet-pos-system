--
-- PostgreSQL database dump
--

\restrict wK02ENBYyu8BUGGgCpKDxpAupW0VO2VhKJw6Mer8iyeeswH2tl6YQoJOxpkb84v

-- Dumped from database version 14.19 (Ubuntu 14.19-1.pgdg22.04+1)
-- Dumped by pg_dump version 17.6 (Ubuntu 17.6-1.pgdg22.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cache; Type: TABLE; Schema: public; Owner: rono_pos
--

CREATE TABLE public.cache (
    key character varying(255) NOT NULL,
    value text NOT NULL,
    expiration integer NOT NULL
);


ALTER TABLE public.cache OWNER TO rono_pos;

--
-- Name: cache_locks; Type: TABLE; Schema: public; Owner: rono_pos
--

CREATE TABLE public.cache_locks (
    key character varying(255) NOT NULL,
    owner character varying(255) NOT NULL,
    expiration integer NOT NULL
);


ALTER TABLE public.cache_locks OWNER TO rono_pos;

--
-- Name: failed_jobs; Type: TABLE; Schema: public; Owner: rono_pos
--

CREATE TABLE public.failed_jobs (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    connection text NOT NULL,
    queue text NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.failed_jobs OWNER TO rono_pos;

--
-- Name: failed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: rono_pos
--

CREATE SEQUENCE public.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.failed_jobs_id_seq OWNER TO rono_pos;

--
-- Name: failed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: rono_pos
--

ALTER SEQUENCE public.failed_jobs_id_seq OWNED BY public.failed_jobs.id;


--
-- Name: fin_expense_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fin_expense_categories (
    id bigint NOT NULL,
    name character varying(150) NOT NULL,
    description character varying(255),
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.fin_expense_categories OWNER TO postgres;

--
-- Name: fin_expense_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fin_expense_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fin_expense_categories_id_seq OWNER TO postgres;

--
-- Name: fin_expense_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fin_expense_categories_id_seq OWNED BY public.fin_expense_categories.id;


--
-- Name: fin_expenses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fin_expenses (
    id bigint NOT NULL,
    category_id bigint,
    amount numeric(12,2) NOT NULL,
    expense_date date DEFAULT CURRENT_DATE,
    description character varying(255),
    recorded_by bigint,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.fin_expenses OWNER TO postgres;

--
-- Name: fin_expenses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fin_expenses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fin_expenses_id_seq OWNER TO postgres;

--
-- Name: fin_expenses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fin_expenses_id_seq OWNED BY public.fin_expenses.id;


--
-- Name: inv_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inv_categories (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    description character varying(255),
    is_enabled boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone
);


ALTER TABLE public.inv_categories OWNER TO postgres;

--
-- Name: inv_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.inv_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.inv_categories_id_seq OWNER TO postgres;

--
-- Name: inv_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.inv_categories_id_seq OWNED BY public.inv_categories.id;


--
-- Name: inv_product_units; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inv_product_units (
    id bigint NOT NULL,
    name character varying(50) NOT NULL,
    is_enabled boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    description character varying
);


ALTER TABLE public.inv_product_units OWNER TO postgres;

--
-- Name: inv_product_units_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.inv_product_units_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.inv_product_units_id_seq OWNER TO postgres;

--
-- Name: inv_product_units_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.inv_product_units_id_seq OWNED BY public.inv_product_units.id;


--
-- Name: inv_products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inv_products (
    id bigint NOT NULL,
    category_id bigint,
    name character varying(150) NOT NULL,
    description character varying(255),
    unit_price numeric(12,2) DEFAULT 0.00 NOT NULL,
    stock_quantity integer DEFAULT 0,
    is_enabled boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    supplier_id bigint,
    sku character varying(100),
    low_stock_threshold integer DEFAULT 10,
    unit_id bigint
);


ALTER TABLE public.inv_products OWNER TO postgres;

--
-- Name: inv_products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.inv_products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.inv_products_id_seq OWNER TO postgres;

--
-- Name: inv_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.inv_products_id_seq OWNED BY public.inv_products.id;


--
-- Name: inv_stock_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inv_stock_history (
    id integer NOT NULL,
    product_id integer NOT NULL,
    delta integer NOT NULL,
    previous_quantity integer NOT NULL,
    new_quantity integer NOT NULL,
    reason character varying(255),
    adjusted_by character varying(100) DEFAULT 'system'::character varying,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.inv_stock_history OWNER TO postgres;

--
-- Name: inv_stock_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.inv_stock_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.inv_stock_history_id_seq OWNER TO postgres;

--
-- Name: inv_stock_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.inv_stock_history_id_seq OWNED BY public.inv_stock_history.id;


--
-- Name: inv_stock_movements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inv_stock_movements (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    delta integer NOT NULL,
    old_quantity integer NOT NULL,
    new_quantity integer NOT NULL,
    reason character varying(255),
    user_id bigint,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.inv_stock_movements OWNER TO postgres;

--
-- Name: inv_stock_movements_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.inv_stock_movements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.inv_stock_movements_id_seq OWNER TO postgres;

--
-- Name: inv_stock_movements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.inv_stock_movements_id_seq OWNED BY public.inv_stock_movements.id;


--
-- Name: inv_suppliers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inv_suppliers (
    id bigint NOT NULL,
    name character varying(150) NOT NULL,
    contact_person character varying(150),
    phone_number character varying(50),
    email character varying(100),
    address character varying(255),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.inv_suppliers OWNER TO postgres;

--
-- Name: inv_suppliers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.inv_suppliers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.inv_suppliers_id_seq OWNER TO postgres;

--
-- Name: inv_suppliers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.inv_suppliers_id_seq OWNED BY public.inv_suppliers.id;


--
-- Name: job_batches; Type: TABLE; Schema: public; Owner: rono_pos
--

CREATE TABLE public.job_batches (
    id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    total_jobs integer NOT NULL,
    pending_jobs integer NOT NULL,
    failed_jobs integer NOT NULL,
    failed_job_ids text NOT NULL,
    options text,
    cancelled_at integer,
    created_at integer NOT NULL,
    finished_at integer
);


ALTER TABLE public.job_batches OWNER TO rono_pos;

--
-- Name: jobs; Type: TABLE; Schema: public; Owner: rono_pos
--

CREATE TABLE public.jobs (
    id bigint NOT NULL,
    queue character varying(255) NOT NULL,
    payload text NOT NULL,
    attempts smallint NOT NULL,
    reserved_at integer,
    available_at integer NOT NULL,
    created_at integer NOT NULL
);


ALTER TABLE public.jobs OWNER TO rono_pos;

--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: rono_pos
--

CREATE SEQUENCE public.jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.jobs_id_seq OWNER TO rono_pos;

--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: rono_pos
--

ALTER SEQUENCE public.jobs_id_seq OWNED BY public.jobs.id;


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: rono_pos
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);


ALTER TABLE public.migrations OWNER TO rono_pos;

--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: rono_pos
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.migrations_id_seq OWNER TO rono_pos;

--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: rono_pos
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: rono_pos
--

CREATE TABLE public.password_reset_tokens (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);


ALTER TABLE public.password_reset_tokens OWNER TO rono_pos;

--
-- Name: personal_access_tokens; Type: TABLE; Schema: public; Owner: rono_pos
--

CREATE TABLE public.personal_access_tokens (
    id bigint NOT NULL,
    tokenable_type character varying(255) NOT NULL,
    tokenable_id bigint NOT NULL,
    name text NOT NULL,
    token character varying(64) NOT NULL,
    abilities text,
    last_used_at timestamp(0) without time zone,
    expires_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.personal_access_tokens OWNER TO rono_pos;

--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: rono_pos
--

CREATE SEQUENCE public.personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.personal_access_tokens_id_seq OWNER TO rono_pos;

--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: rono_pos
--

ALTER SEQUENCE public.personal_access_tokens_id_seq OWNED BY public.personal_access_tokens.id;


--
-- Name: pos_customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pos_customers (
    id bigint NOT NULL,
    name character varying(150) NOT NULL,
    phone_number character varying(50),
    email character varying(100),
    address character varying(255),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.pos_customers OWNER TO postgres;

--
-- Name: pos_customers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pos_customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pos_customers_id_seq OWNER TO postgres;

--
-- Name: pos_customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pos_customers_id_seq OWNED BY public.pos_customers.id;


--
-- Name: pos_sale_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pos_sale_items (
    id bigint NOT NULL,
    sale_id bigint,
    product_id bigint,
    quantity integer NOT NULL,
    unit_price numeric(12,2) NOT NULL,
    subtotal numeric(12,2) NOT NULL,
    unit_id bigint
);


ALTER TABLE public.pos_sale_items OWNER TO postgres;

--
-- Name: pos_sale_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pos_sale_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pos_sale_items_id_seq OWNER TO postgres;

--
-- Name: pos_sale_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pos_sale_items_id_seq OWNED BY public.pos_sale_items.id;


--
-- Name: pos_sales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pos_sales (
    id bigint NOT NULL,
    user_id bigint,
    total_amount numeric(12,2) NOT NULL,
    payment_method character varying(50) DEFAULT 'Cash'::character varying,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    customer_id bigint,
    receipt_no character varying(50)
);


ALTER TABLE public.pos_sales OWNER TO postgres;

--
-- Name: pos_sales_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pos_sales_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pos_sales_id_seq OWNER TO postgres;

--
-- Name: pos_sales_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pos_sales_id_seq OWNED BY public.pos_sales.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: rono_pos
--

CREATE TABLE public.sessions (
    id character varying(255) NOT NULL,
    user_id bigint,
    ip_address character varying(45),
    user_agent text,
    payload text NOT NULL,
    last_activity integer NOT NULL
);


ALTER TABLE public.sessions OWNER TO rono_pos;

--
-- Name: users; Type: TABLE; Schema: public; Owner: rono_pos
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    email_verified_at timestamp(0) without time zone,
    password character varying(255) NOT NULL,
    remember_token character varying(100),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.users OWNER TO rono_pos;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: rono_pos
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO rono_pos;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: rono_pos
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: usr_failed_logins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usr_failed_logins (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    ip_address character varying(45),
    attempted_at timestamp without time zone DEFAULT now(),
    reason text
);


ALTER TABLE public.usr_failed_logins OWNER TO postgres;

--
-- Name: usr_failed_logins_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usr_failed_logins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usr_failed_logins_id_seq OWNER TO postgres;

--
-- Name: usr_failed_logins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usr_failed_logins_id_seq OWNED BY public.usr_failed_logins.id;


--
-- Name: usr_permission_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usr_permission_role (
    id bigint NOT NULL,
    permission_id bigint,
    role_id bigint,
    assigned_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.usr_permission_role OWNER TO postgres;

--
-- Name: usr_permission_role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usr_permission_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usr_permission_role_id_seq OWNER TO postgres;

--
-- Name: usr_permission_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usr_permission_role_id_seq OWNED BY public.usr_permission_role.id;


--
-- Name: usr_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usr_permissions (
    id bigint NOT NULL,
    name character varying(150) NOT NULL,
    code character varying(100) NOT NULL,
    description character varying(255),
    created_at timestamp without time zone DEFAULT now(),
    navigation_item_id bigint,
    updated_at timestamp without time zone
);


ALTER TABLE public.usr_permissions OWNER TO postgres;

--
-- Name: usr_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usr_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usr_permissions_id_seq OWNER TO postgres;

--
-- Name: usr_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usr_permissions_id_seq OWNED BY public.usr_permissions.id;


--
-- Name: usr_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usr_roles (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    description character varying(255),
    is_default boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.usr_roles OWNER TO postgres;

--
-- Name: usr_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usr_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usr_roles_id_seq OWNER TO postgres;

--
-- Name: usr_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usr_roles_id_seq OWNED BY public.usr_roles.id;


--
-- Name: usr_user_group_mapping; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usr_user_group_mapping (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    user_group_id bigint NOT NULL,
    created_on timestamp without time zone DEFAULT now()
);


ALTER TABLE public.usr_user_group_mapping OWNER TO postgres;

--
-- Name: usr_user_group_mapping_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usr_user_group_mapping_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usr_user_group_mapping_id_seq OWNER TO postgres;

--
-- Name: usr_user_group_mapping_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usr_user_group_mapping_id_seq OWNED BY public.usr_user_group_mapping.id;


--
-- Name: usr_user_logins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usr_user_logins (
    id integer NOT NULL,
    user_id bigint NOT NULL,
    ip_address character varying(50),
    logged_in_at timestamp without time zone DEFAULT now(),
    logged_out_at timestamp without time zone
);


ALTER TABLE public.usr_user_logins OWNER TO postgres;

--
-- Name: usr_user_logins_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usr_user_logins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usr_user_logins_id_seq OWNER TO postgres;

--
-- Name: usr_user_logins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usr_user_logins_id_seq OWNED BY public.usr_user_logins.id;


--
-- Name: usr_user_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usr_user_roles (
    id bigint NOT NULL,
    user_id bigint,
    role_id bigint,
    assigned_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.usr_user_roles OWNER TO postgres;

--
-- Name: usr_user_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usr_user_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usr_user_roles_id_seq OWNER TO postgres;

--
-- Name: usr_user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usr_user_roles_id_seq OWNED BY public.usr_user_roles.id;


--
-- Name: usr_usergroups_navigation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usr_usergroups_navigation (
    id bigint NOT NULL,
    usergroup_id bigint NOT NULL,
    navigation_item_id bigint NOT NULL,
    can_view boolean DEFAULT true,
    can_create boolean DEFAULT false,
    can_edit boolean DEFAULT false,
    can_delete boolean DEFAULT false,
    created_on timestamp without time zone DEFAULT now()
);


ALTER TABLE public.usr_usergroups_navigation OWNER TO postgres;

--
-- Name: usr_usergroups_navigation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usr_usergroups_navigation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usr_usergroups_navigation_id_seq OWNER TO postgres;

--
-- Name: usr_usergroups_navigation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usr_usergroups_navigation_id_seq OWNED BY public.usr_usergroups_navigation.id;


--
-- Name: usr_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usr_users (
    id bigint NOT NULL,
    name character varying(150) NOT NULL,
    email character varying(150) NOT NULL,
    password character varying(255) NOT NULL,
    is_enabled boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    remember_token character varying(100)
);


ALTER TABLE public.usr_users OWNER TO postgres;

--
-- Name: usr_users_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usr_users_groups (
    id bigint NOT NULL,
    name character varying(250) NOT NULL,
    description character varying(500),
    code character varying(100),
    is_enabled boolean DEFAULT true,
    created_by character varying(50),
    created_on timestamp without time zone DEFAULT now(),
    altered_by character varying(50),
    dola date,
    is_super_admin boolean DEFAULT false,
    account_type_id bigint DEFAULT 0,
    order_no integer,
    institution_type_id bigint DEFAULT 0,
    is_default_usergroup boolean DEFAULT false,
    organisation_id bigint DEFAULT 0,
    user_group_id bigint
);


ALTER TABLE public.usr_users_groups OWNER TO postgres;

--
-- Name: usr_users_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usr_users_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usr_users_groups_id_seq OWNER TO postgres;

--
-- Name: usr_users_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usr_users_groups_id_seq OWNED BY public.usr_users_groups.id;


--
-- Name: usr_users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usr_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usr_users_id_seq OWNER TO postgres;

--
-- Name: usr_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usr_users_id_seq OWNED BY public.usr_users.id;


--
-- Name: usr_users_information; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usr_users_information (
    id bigint NOT NULL,
    user_id bigint,
    phone_number character varying(50),
    address character varying(255),
    gender character varying(10),
    dob date,
    profile_photo character varying(255),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.usr_users_information OWNER TO postgres;

--
-- Name: usr_users_information_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usr_users_information_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usr_users_information_id_seq OWNER TO postgres;

--
-- Name: usr_users_information_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usr_users_information_id_seq OWNED BY public.usr_users_information.id;


--
-- Name: wf_navigation_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wf_navigation_items (
    id bigint NOT NULL,
    description character varying(255),
    is_enabled boolean DEFAULT true,
    parent_id bigint,
    level bigint DEFAULT 1 NOT NULL,
    created_by character varying(50),
    created_on timestamp without time zone DEFAULT now(),
    altered_by character varying(50),
    code character varying(255),
    dola date,
    system_interface_id bigint,
    navigation_type_id bigint,
    icons_cls character varying(100),
    system_label_id bigint,
    name character varying(255),
    order_no integer,
    regulatory_function_id integer,
    account_type_id integer,
    regulatory_subfunction_id integer,
    appworkflowstage_category_id integer,
    has_appworkflowstage_category boolean DEFAULT false,
    has_initiateapplication_option boolean DEFAULT false,
    nav_routerlink character varying(255)
);


ALTER TABLE public.wf_navigation_items OWNER TO postgres;

--
-- Name: wf_navigation_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.wf_navigation_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.wf_navigation_items_id_seq OWNER TO postgres;

--
-- Name: wf_navigation_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.wf_navigation_items_id_seq OWNED BY public.wf_navigation_items.id;


--
-- Name: wf_navigation_levels; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wf_navigation_levels (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(500),
    code character varying(255),
    is_enabled boolean DEFAULT true,
    created_by character varying(50),
    created_on timestamp without time zone DEFAULT now(),
    altered_by character varying(50),
    order_no integer,
    navigation_type_id integer
);


ALTER TABLE public.wf_navigation_levels OWNER TO postgres;

--
-- Name: wf_navigation_levels_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.wf_navigation_levels_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.wf_navigation_levels_id_seq OWNER TO postgres;

--
-- Name: wf_navigation_levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.wf_navigation_levels_id_seq OWNED BY public.wf_navigation_levels.id;


--
-- Name: wf_navigation_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wf_navigation_permissions (
    id bigint NOT NULL,
    user_group_id bigint,
    navigation_item_id bigint,
    can_view boolean DEFAULT true,
    can_create boolean DEFAULT false,
    can_edit boolean DEFAULT false,
    can_delete boolean DEFAULT false,
    created_on timestamp without time zone DEFAULT now()
);


ALTER TABLE public.wf_navigation_permissions OWNER TO postgres;

--
-- Name: wf_navigation_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.wf_navigation_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.wf_navigation_permissions_id_seq OWNER TO postgres;

--
-- Name: wf_navigation_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.wf_navigation_permissions_id_seq OWNED BY public.wf_navigation_permissions.id;


--
-- Name: wf_navigation_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wf_navigation_types (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    is_enabled boolean DEFAULT true,
    created_by character varying(50),
    created_on timestamp without time zone DEFAULT now(),
    altered_by character varying(50),
    code character varying(255),
    dola date,
    order_no character varying(255),
    iso_acyronym character varying(50)
);


ALTER TABLE public.wf_navigation_types OWNER TO postgres;

--
-- Name: wf_navigation_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.wf_navigation_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.wf_navigation_types_id_seq OWNER TO postgres;

--
-- Name: wf_navigation_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.wf_navigation_types_id_seq OWNED BY public.wf_navigation_types.id;


--
-- Name: failed_jobs id; Type: DEFAULT; Schema: public; Owner: rono_pos
--

ALTER TABLE ONLY public.failed_jobs ALTER COLUMN id SET DEFAULT nextval('public.failed_jobs_id_seq'::regclass);


--
-- Name: fin_expense_categories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fin_expense_categories ALTER COLUMN id SET DEFAULT nextval('public.fin_expense_categories_id_seq'::regclass);


--
-- Name: fin_expenses id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fin_expenses ALTER COLUMN id SET DEFAULT nextval('public.fin_expenses_id_seq'::regclass);


--
-- Name: inv_categories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inv_categories ALTER COLUMN id SET DEFAULT nextval('public.inv_categories_id_seq'::regclass);


--
-- Name: inv_product_units id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inv_product_units ALTER COLUMN id SET DEFAULT nextval('public.inv_product_units_id_seq'::regclass);


--
-- Name: inv_products id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inv_products ALTER COLUMN id SET DEFAULT nextval('public.inv_products_id_seq'::regclass);


--
-- Name: inv_stock_history id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inv_stock_history ALTER COLUMN id SET DEFAULT nextval('public.inv_stock_history_id_seq'::regclass);


--
-- Name: inv_stock_movements id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inv_stock_movements ALTER COLUMN id SET DEFAULT nextval('public.inv_stock_movements_id_seq'::regclass);


--
-- Name: inv_suppliers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inv_suppliers ALTER COLUMN id SET DEFAULT nextval('public.inv_suppliers_id_seq'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: rono_pos
--

ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public.jobs_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: rono_pos
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: personal_access_tokens id; Type: DEFAULT; Schema: public; Owner: rono_pos
--

ALTER TABLE ONLY public.personal_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.personal_access_tokens_id_seq'::regclass);


--
-- Name: pos_customers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pos_customers ALTER COLUMN id SET DEFAULT nextval('public.pos_customers_id_seq'::regclass);


--
-- Name: pos_sale_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pos_sale_items ALTER COLUMN id SET DEFAULT nextval('public.pos_sale_items_id_seq'::regclass);


--
-- Name: pos_sales id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pos_sales ALTER COLUMN id SET DEFAULT nextval('public.pos_sales_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: rono_pos
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: usr_failed_logins id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_failed_logins ALTER COLUMN id SET DEFAULT nextval('public.usr_failed_logins_id_seq'::regclass);


--
-- Name: usr_permission_role id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_permission_role ALTER COLUMN id SET DEFAULT nextval('public.usr_permission_role_id_seq'::regclass);


--
-- Name: usr_permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_permissions ALTER COLUMN id SET DEFAULT nextval('public.usr_permissions_id_seq'::regclass);


--
-- Name: usr_roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_roles ALTER COLUMN id SET DEFAULT nextval('public.usr_roles_id_seq'::regclass);


--
-- Name: usr_user_group_mapping id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_user_group_mapping ALTER COLUMN id SET DEFAULT nextval('public.usr_user_group_mapping_id_seq'::regclass);


--
-- Name: usr_user_logins id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_user_logins ALTER COLUMN id SET DEFAULT nextval('public.usr_user_logins_id_seq'::regclass);


--
-- Name: usr_user_roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_user_roles ALTER COLUMN id SET DEFAULT nextval('public.usr_user_roles_id_seq'::regclass);


--
-- Name: usr_usergroups_navigation id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_usergroups_navigation ALTER COLUMN id SET DEFAULT nextval('public.usr_usergroups_navigation_id_seq'::regclass);


--
-- Name: usr_users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_users ALTER COLUMN id SET DEFAULT nextval('public.usr_users_id_seq'::regclass);


--
-- Name: usr_users_groups id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_users_groups ALTER COLUMN id SET DEFAULT nextval('public.usr_users_groups_id_seq'::regclass);


--
-- Name: usr_users_information id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_users_information ALTER COLUMN id SET DEFAULT nextval('public.usr_users_information_id_seq'::regclass);


--
-- Name: wf_navigation_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wf_navigation_items ALTER COLUMN id SET DEFAULT nextval('public.wf_navigation_items_id_seq'::regclass);


--
-- Name: wf_navigation_levels id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wf_navigation_levels ALTER COLUMN id SET DEFAULT nextval('public.wf_navigation_levels_id_seq'::regclass);


--
-- Name: wf_navigation_permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wf_navigation_permissions ALTER COLUMN id SET DEFAULT nextval('public.wf_navigation_permissions_id_seq'::regclass);


--
-- Name: wf_navigation_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wf_navigation_types ALTER COLUMN id SET DEFAULT nextval('public.wf_navigation_types_id_seq'::regclass);


--
-- Data for Name: cache; Type: TABLE DATA; Schema: public; Owner: rono_pos
--

COPY public.cache (key, value, expiration) FROM stdin;
\.


--
-- Data for Name: cache_locks; Type: TABLE DATA; Schema: public; Owner: rono_pos
--

COPY public.cache_locks (key, owner, expiration) FROM stdin;
\.


--
-- Data for Name: failed_jobs; Type: TABLE DATA; Schema: public; Owner: rono_pos
--

COPY public.failed_jobs (id, uuid, connection, queue, payload, exception, failed_at) FROM stdin;
\.


--
-- Data for Name: fin_expense_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fin_expense_categories (id, name, description, created_at) FROM stdin;
1	Rent	Monthly shop rent	2025-10-10 20:53:24.093276
2	Utilities	Water, electricity, internet	2025-10-10 20:53:24.093276
3	Staff Salaries	Employee payments	2025-10-10 20:53:24.093276
4	Supplies	Office and cleaning supplies	2025-10-10 20:53:24.093276
5	Maintenance	Repairs and maintenance	2025-10-10 20:53:24.093276
\.


--
-- Data for Name: fin_expenses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fin_expenses (id, category_id, amount, expense_date, description, recorded_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: inv_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inv_categories (id, name, description, is_enabled, created_at, updated_at) FROM stdin;
1	Vaccines	Animal vaccination products	t	2025-10-10 20:45:56.328591	\N
2	Dewormers	Anti-parasitic drugs	t	2025-10-10 20:45:56.328591	\N
3	Supplements	Nutritional supplements	t	2025-10-10 20:45:56.328591	\N
7	Feed & Supplements	Animal feed and nutritional supplements	t	2025-10-12 22:57:25.419912	\N
8	Medicines	Veterinary medicines	t	2025-10-12 22:57:25.419912	\N
9	Equipment	Farm and veterinary tools	t	2025-10-12 22:57:25.419912	\N
10	Veterinary Drugs	Medicines and treatments for livestock and pets	t	2025-10-14 00:12:19.319894	2025-10-14 00:12:19.319894
12	Dewormers	Internal and external parasite control products	t	2025-10-14 00:12:19.319894	2025-10-14 00:12:19.319894
13	Animal Feeds	Various livestock and poultry feeds	t	2025-10-14 00:12:19.319894	2025-10-14 00:12:19.319894
14	Feed Additives & Supplements	Vitamins, minerals, and feed enhancers	t	2025-10-14 00:12:19.319894	2025-10-14 00:12:19.319894
15	Farm Equipment	Tools and machinery for livestock and crop farming	t	2025-10-14 00:12:19.319894	2025-10-14 00:12:19.319894
16	Milking Equipment	Buckets, milking machines, filters, and accessories	t	2025-10-14 00:12:19.319894	2025-10-14 00:12:19.319894
17	Fencing Materials	Barbed wire, poles, and electric fencing accessories	t	2025-10-14 00:12:19.319894	2025-10-14 00:12:19.319894
18	Crop Protection Products	Herbicides, pesticides, and fungicides	t	2025-10-14 00:12:19.319894	2025-10-14 00:12:19.319894
19	Seeds & Seedlings	Certified seeds and young plants for crops	t	2025-10-14 00:12:19.319894	2025-10-14 00:12:19.319894
20	Fertilizers	Organic and inorganic fertilizers	t	2025-10-14 00:12:19.319894	2025-10-14 00:12:19.319894
21	Watering & Irrigation	Sprayers, pipes, and irrigation equipment	t	2025-10-14 00:12:19.319894	2025-10-14 00:12:19.319894
22	Pet Care Products	Food, grooming items, and accessories for pets	t	2025-10-14 00:12:19.319894	2025-10-14 00:12:19.319894
23	Disinfectants & Sanitizers	Farm hygiene and cleaning solutions	t	2025-10-14 00:12:19.319894	2025-10-14 00:12:19.319894
24	Protective Clothing	Gloves, overalls, boots, and other safety gear	t	2025-10-14 00:12:19.319894	2025-10-14 00:12:19.319894
11	Acaricides	Acaricides for spraying animals against ticks	t	2025-10-14 00:12:19.319894	2025-10-14 00:12:19.319894
\.


--
-- Data for Name: inv_product_units; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inv_product_units (id, name, is_enabled, created_at, updated_at, description) FROM stdin;
1	10 ml	t	2025-10-17 18:36:29.982636	2025-10-17 18:36:29.982636	\N
2	20ml	t	2025-10-17 18:36:43.58821	2025-10-17 18:36:43.58821	\N
3	50ml	t	2025-10-17 18:36:55.295066	2025-10-17 18:36:55.295066	\N
4	100ml	t	2025-10-17 18:37:06.980705	2025-10-17 18:37:06.980705	\N
5	200ml	t	2025-10-17 18:37:16.246735	2025-10-17 18:37:16.246735	\N
6	500ml	t	2025-10-17 18:37:40.533428	2025-10-17 18:37:40.533428	\N
7	1 Ltr	t	2025-10-17 18:37:54.097647	2025-10-17 18:37:54.097647	\N
8	5 Ltrs	t	2025-10-17 18:38:05.578589	2025-10-17 18:38:05.578589	\N
9	10 Kgs	t	2025-10-17 18:38:18.295189	2025-10-17 18:38:18.295189	\N
10	20 Kgs	t	2025-10-17 18:38:29.360335	2025-10-17 18:38:29.360335	\N
11	50 Kgs	t	2025-10-17 18:38:40.599958	2025-10-17 18:38:40.599958	\N
12	70 Kgs	t	2025-10-17 18:38:50.255376	2025-10-17 18:38:50.255376	\N
13	10 g	t	2025-10-17 18:39:20.662704	2025-10-17 18:39:20.662704	\N
14	20 g	t	2025-10-17 18:39:27.372449	2025-10-17 18:39:27.372449	\N
15	50 g	t	2025-10-17 18:39:38.218256	2025-10-17 18:39:38.218256	\N
16	100 g	t	2025-10-17 18:39:53.10154	2025-10-17 18:39:53.10154	\N
17	200 g	t	2025-10-17 18:40:02.267142	2025-10-17 18:40:02.267142	\N
18	250 g	t	2025-10-17 18:40:12.779742	2025-10-17 18:40:12.779742	\N
19	500 g	t	2025-10-17 18:40:24.064862	2025-10-17 18:40:24.064862	\N
20	2 Kgs	t	2025-10-17 18:40:36.296796	2025-10-17 18:40:36.296796	\N
21	3 Kgs	t	2025-10-17 18:40:45.143773	2025-10-17 18:40:45.143773	\N
22	5 Kgs	t	2025-10-17 18:40:57.945827	2025-10-17 18:40:57.945827	\N
\.


--
-- Data for Name: inv_products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inv_products (id, category_id, name, description, unit_price, stock_quantity, is_enabled, created_at, updated_at, supplier_id, sku, low_stock_threshold, unit_id) FROM stdin;
7	18	EasyGro	\N	250.00	0	t	2025-10-19 18:03:01	2025-10-19 18:03:01	\N	\N	10	18
6	1	Ivamectin	\N	2000.00	3	t	2025-10-17 16:22:06	2025-10-19 21:13:34.346954	\N	\N	10	4
4	11	Ectomin	\N	180.00	17	t	2025-10-14 18:04:40	2025-10-19 21:45:13.786065	\N	\N	10	3
3	23	Vetmicin	\N	450.00	13	t	2025-10-13 21:19:29	2025-10-19 21:51:51.219027	\N	\N	10	5
2	16	Milking Salve	\N	200.00	10	t	2025-10-13 20:48:24	2025-10-20 14:19:15.90752	\N	\N	10	4
5	13	Dairy meal	\N	2400.00	19	t	2025-10-17 15:29:14	2025-10-23 23:25:18.126373	\N	\N	10	12
1	11	Duodip	\N	380.00	10	t	2025-10-13 20:40:07	2025-10-24 00:12:01.814666	\N	\N	10	4
\.


--
-- Data for Name: inv_stock_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inv_stock_history (id, product_id, delta, previous_quantity, new_quantity, reason, adjusted_by, created_at) FROM stdin;
1	4	1	0	1	Manual Adjustment	Admin	2025-10-15 00:34:19.001806
2	4	1	1	2	Manual Adjustment	Admin	2025-10-15 21:42:39.067994
3	4	1	2	3	Manual Adjustment	Admin	2025-10-15 21:42:40.236478
4	4	1	3	4	Manual Adjustment	Admin	2025-10-15 21:42:41.787064
5	4	1	4	5	Manual Adjustment	Admin	2025-10-15 21:42:42.752106
6	4	1	5	6	Manual Adjustment	Admin	2025-10-15 21:42:42.936747
7	4	1	6	7	Manual Adjustment	Admin	2025-10-15 21:42:43.119194
8	3	1	8	9	Manual Adjustment	Admin	2025-10-15 21:42:43.966102
9	3	1	9	10	Manual Adjustment	Admin	2025-10-15 21:42:44.189464
10	3	1	10	11	Manual Adjustment	Admin	2025-10-15 21:42:44.31387
11	4	1	7	8	Manual Adjustment	Admin	2025-10-15 21:47:32.2877
12	4	1	8	9	Manual Adjustment	Admin	2025-10-15 21:47:37.502313
13	2	1	11	12	Manual Adjustment	Admin	2025-10-15 21:48:14.041362
14	4	-1	9	8	Manual Adjustment	Admin	2025-10-15 21:48:23.048945
15	4	2	8	10	Stock replenishment	Admin	2025-10-15 21:59:27.548452
16	4	2	10	12	Stock replenishment	Admin	2025-10-15 21:59:29.281424
17	4	1	12	13	Manual Adjustment	Admin	2025-10-15 22:14:51.754752
18	4	1	13	14	Manual Adjustment	Admin	2025-10-15 22:14:53.763141
19	4	-1	14	13	Manual Adjustment	Admin	2025-10-15 22:14:57.101949
20	4	-1	13	12	Manual Adjustment	Admin	2025-10-15 22:14:58.084075
21	4	1	12	13	New Stock Received	Admin	2025-10-15 22:22:45.156063
22	4	1	13	14	New Stock Received	Admin	2025-10-15 22:24:43.382257
23	4	1	14	15	New Stock Received	Admin	2025-10-15 22:24:44.62517
24	4	1	15	16	New Stock Received	Admin	2025-10-15 22:24:53.347402
25	3	1	11	12	New Stock Received	Admin	2025-10-15 22:28:32.109295
26	3	1	12	13	New Stock Received	Admin	2025-10-15 22:47:17.547478
27	4	1	16	17	New Stock Received	Admin	2025-10-15 22:48:34.428335
28	4	1	17	18	New Stock Received	Admin	2025-10-15 22:48:36.37332
29	4	1	18	19	New Stock Received	Admin	2025-10-15 22:48:42.299844
30	4	1	19	20	Manual Adjustment	Admin	2025-10-15 22:49:12.128539
31	4	-1	20	19	Manual Adjustment	Admin	2025-10-15 22:49:13.415391
32	4	-1	19	18	Manual Adjustment	Admin	2025-10-15 22:49:13.798083
33	4	-1	18	17	Manual Adjustment	Admin	2025-10-15 22:49:14.08416
34	4	-1	17	16	Manual Adjustment	Admin	2025-10-15 22:49:14.313012
35	4	1	16	17	New Stock Received	Admin	2025-10-15 22:54:03.641293
36	4	1	17	18	New Stock Received	Admin	2025-10-15 22:57:30.091895
37	4	1	18	19	New Stock Received	Admin	2025-10-15 23:02:09.385792
38	4	1	19	20	New Stock Received	Admin	2025-10-15 23:06:51.130521
39	3	1	13	14	New Stock Received	Admin	2025-10-15 23:31:59.155081
40	4	1	17	18	Manual Adjustment	Admin	2025-10-17 16:12:55.588833
41	4	-1	18	17	Manual Adjustment	Admin	2025-10-17 16:12:58.136851
42	4	1	17	18	Manual Adjustment	Admin	2025-10-17 16:13:00.014953
43	4	-1	18	17	Manual Adjustment	Admin	2025-10-17 16:13:01.511939
44	4	1	17	18	Manual Adjustment	Admin	2025-10-17 16:13:02.762204
45	3	1	14	15	Manual Adjustment	Admin	2025-10-17 16:13:04.295812
46	1	1	17	18	Manual Adjustment	Admin	2025-10-17 16:13:36.478238
47	4	1	18	19	New Stock Received	Admin	2025-10-17 16:15:45.726043
48	4	1	19	20	Manual Adjustment	Admin	2025-10-17 16:15:49.191756
49	3	-1	15	14	Manual Adjustment	Admin	2025-10-17 16:15:55.684378
50	3	1	14	15	Manual Adjustment	Admin	2025-10-17 16:19:29.519522
51	5	1	0	1	New Stock Received	Admin	2025-10-17 18:33:50.218989
52	5	1	1	2	Manual Adjustment	Admin	2025-10-17 19:06:18.006031
53	5	-1	2	1	Manual Adjustment	Admin	2025-10-17 19:06:22.932617
54	5	24	1	25	New Stock Received	Admin	2025-10-17 19:06:31.959383
55	1	1	18	19	Manual Adjustment	Admin	2025-10-17 19:20:02.118979
56	1	1	19	20	Manual Adjustment	Admin	2025-10-17 19:20:02.255716
57	1	1	20	21	Manual Adjustment	Admin	2025-10-17 19:20:03.455968
58	6	2	2	4	New Stock Received	Admin	2025-10-17 20:48:25.195428
\.


--
-- Data for Name: inv_stock_movements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inv_stock_movements (id, product_id, delta, old_quantity, new_quantity, reason, user_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: inv_suppliers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inv_suppliers (id, name, contact_person, phone_number, email, address, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: job_batches; Type: TABLE DATA; Schema: public; Owner: rono_pos
--

COPY public.job_batches (id, name, total_jobs, pending_jobs, failed_jobs, failed_job_ids, options, cancelled_at, created_at, finished_at) FROM stdin;
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: rono_pos
--

COPY public.jobs (id, queue, payload, attempts, reserved_at, available_at, created_at) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: rono_pos
--

COPY public.migrations (id, migration, batch) FROM stdin;
1	0001_01_01_000000_create_users_table	1
2	0001_01_01_000001_create_cache_table	1
3	0001_01_01_000002_create_jobs_table	1
4	2025_10_11_103202_create_personal_access_tokens_table	2
5	2025_10_19_083549_create_personal_access_tokens_table	3
\.


--
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: rono_pos
--

COPY public.password_reset_tokens (email, token, created_at) FROM stdin;
\.


--
-- Data for Name: personal_access_tokens; Type: TABLE DATA; Schema: public; Owner: rono_pos
--

COPY public.personal_access_tokens (id, tokenable_type, tokenable_id, name, token, abilities, last_used_at, expires_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: pos_customers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pos_customers (id, name, phone_number, email, address, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: pos_sale_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pos_sale_items (id, sale_id, product_id, quantity, unit_price, subtotal, unit_id) FROM stdin;
1	2	1	1	200.00	200.00	\N
3	11	1	1	200.00	200.00	\N
4	12	6	1	2000.00	2000.00	4
5	12	3	1	450.00	450.00	5
6	12	1	1	380.00	380.00	4
7	13	5	1	2400.00	2400.00	12
8	14	5	1	2400.00	2400.00	12
9	15	4	1	180.00	180.00	3
10	16	5	1	2400.00	2400.00	12
11	17	5	1	2400.00	2400.00	12
12	18	1	1	380.00	380.00	4
13	19	1	1	380.00	380.00	4
14	20	4	1	180.00	180.00	3
15	21	4	1	180.00	180.00	3
16	22	1	2	380.00	760.00	4
17	23	3	1	450.00	450.00	5
18	24	1	1	380.00	380.00	4
19	25	5	1	2400.00	2400.00	12
20	26	1	1	380.00	380.00	4
21	27	2	1	200.00	200.00	4
22	28	2	1	200.00	200.00	4
23	29	1	1	380.00	380.00	4
24	30	5	1	2400.00	2400.00	12
25	31	1	1	380.00	380.00	4
\.


--
-- Data for Name: pos_sales; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pos_sales (id, user_id, total_amount, payment_method, created_at, updated_at, customer_id, receipt_no) FROM stdin;
2	\N	200.00	Cash	2025-10-19 09:49:54.677235	2025-10-19 09:49:54.677235	\N	RCPT-20251019-0001
11	\N	200.00	Cash	2025-10-19 20:51:58.515676	2025-10-19 20:51:58.515676	\N	RCPT-20251019-0002
12	\N	2830.00	Cash	2025-10-19 21:13:34.346954	2025-10-19 21:13:34.346954	\N	RCPT-20251019-0003
13	\N	2400.00	Cash	2025-10-19 21:18:09.515049	2025-10-19 21:18:09.515049	\N	RCPT-20251019-0004
14	\N	2400.00	Cash	2025-10-19 21:30:32.425405	2025-10-19 21:30:32.425405	\N	RCPT-20251019-0005
15	\N	180.00	Cash	2025-10-19 21:32:13.884055	2025-10-19 21:32:13.884055	\N	RCPT-20251019-0006
16	\N	2400.00	Cash	2025-10-19 21:33:20.361295	2025-10-19 21:33:20.361295	\N	RCPT-20251019-0007
17	\N	2400.00	Cash	2025-10-19 21:35:50.663559	2025-10-19 21:35:50.663559	\N	RCPT-20251019-0008
18	\N	380.00	Cash	2025-10-19 21:37:01.025781	2025-10-19 21:37:01.025781	\N	RCPT-20251019-0009
19	\N	380.00	Cash	2025-10-19 21:38:27.153374	2025-10-19 21:38:27.153374	\N	RCPT-20251019-0010
20	\N	180.00	Cash	2025-10-19 21:42:22.418988	2025-10-19 21:42:22.418988	\N	RCPT-20251019-0011
21	\N	180.00	Cash	2025-10-19 21:45:13.786065	2025-10-19 21:45:13.786065	\N	RCPT-20251019-0012
22	\N	760.00	Cash	2025-10-19 21:47:32.737948	2025-10-19 21:47:32.737948	\N	RCPT-20251019-0013
23	\N	450.00	Cash	2025-10-19 21:51:51.219027	2025-10-19 21:51:51.219027	\N	RCPT-20251019-0014
24	\N	380.00	Cash	2025-10-19 22:02:20.997912	2025-10-19 22:02:20.997912	\N	RCPT-20251019-0015
25	\N	2400.00	Cash	2025-10-19 22:03:57.182669	2025-10-19 22:03:57.182669	\N	RCPT-20251019-0016
26	\N	380.00	Cash	2025-10-19 22:07:15.039156	2025-10-19 22:07:15.039156	\N	RCPT-20251019-0017
27	\N	200.00	Cash	2025-10-20 00:36:26.553941	2025-10-20 00:36:26.553941	\N	RCPT-20251019-0018
28	\N	200.00	Mpesa	2025-10-20 14:19:15.90752	2025-10-20 14:19:15.90752	\N	RCPT-20251020-0002
29	\N	380.00	Cash	2025-10-23 22:37:33.444036	2025-10-23 22:37:33.444036	\N	RCPT-20251023-0001
30	\N	2400.00	Cash	2025-10-23 23:25:18.126373	2025-10-23 23:25:18.126373	\N	RCPT-20251023-0002
31	\N	380.00	Cash	2025-10-24 00:12:01.814666	2025-10-24 00:12:01.814666	\N	RCPT-20251023-0003
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: rono_pos
--

COPY public.sessions (id, user_id, ip_address, user_agent, payload, last_activity) FROM stdin;
KQgbLsNcGoqzD7gOwgedzaI3lVcyt2TcECXDTaLe	\N	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	YTozOntzOjY6Il90b2tlbiI7czo0MDoidGxDRGNNSUVoSGFBMWZWTDBSOUpkcG1NWHhhV3dvWW1yWmphc1RUZiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6Nzg6Imh0dHA6Ly92ZXRwb3MubG9jYWw6ODQvcmVzb3VyY2VzL25vZGVfbW9kdWxlcy9kZXZleHRyZW1lL2Rpc3QvY3NzL2R4LmxpZ2h0LmNzcyI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=	1761385035
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: rono_pos
--

COPY public.users (id, name, email, email_verified_at, password, remember_token, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: usr_failed_logins; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usr_failed_logins (id, email, ip_address, attempted_at, reason) FROM stdin;
1	admin@vetpos.com	127.0.0.1	2025-10-18 09:57:34	Invalid password
2	admin@vetpos.com	127.0.0.1	2025-10-18 10:20:09	User not found
3	admin@vetpos.com	127.0.0.1	2025-10-18 10:21:14	User not found
4	admin@example.com	127.0.0.1	2025-10-18 10:23:20	User not found
5	admin@example.com	127.0.0.1	2025-10-18 10:24:25	User not found
6	admin@vetpos.com	127.0.0.1	2025-10-18 11:39:30	User not found
7	admin@example.com	127.0.0.1	2025-10-18 11:45:12	User not found
8	admin@example.com	127.0.0.1	2025-10-18 11:46:13	User not found
9	admin@example.com	127.0.0.1	2025-10-18 11:46:44	User not found
\.


--
-- Data for Name: usr_permission_role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usr_permission_role (id, permission_id, role_id, assigned_at) FROM stdin;
1	1	1	2025-10-10 20:52:31.322814
2	2	1	2025-10-10 20:52:31.322814
4	4	1	2025-10-10 20:52:31.322814
5	5	1	2025-10-10 20:52:31.322814
6	6	1	2025-10-10 20:52:31.322814
7	7	1	2025-10-10 20:52:31.322814
8	8	1	2025-10-10 20:52:31.322814
9	1	2	2025-10-23 09:08:03.356497
12	1	3	2025-10-23 09:08:55.965475
13	2	3	2025-10-23 09:08:55.965475
15	4	3	2025-10-23 09:08:55.965475
16	6	3	2025-10-23 09:08:55.965475
17	7	3	2025-10-23 09:08:55.965475
18	9	1	2025-10-23 19:12:41.498159
19	9	2	2025-10-23 19:12:41.498159
20	9	3	2025-10-23 19:12:41.498159
21	9	1	2025-10-23 19:50:31.250435
22	9	3	2025-10-23 19:50:43.17275
23	10	1	2025-10-23 19:54:26.359234
24	11	1	2025-10-23 19:58:16.738822
26	11	3	2025-10-23 19:58:16.738822
27	6	2	2025-10-23 21:19:02.422377
\.


--
-- Data for Name: usr_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usr_permissions (id, name, code, description, created_at, navigation_item_id, updated_at) FROM stdin;
1	Dashboard	view_dashboard	Access dashboard overview	2025-10-10 20:52:31.322814	9	2025-10-23 18:51:07.735686
2	Inventory	manage_products	Create, update, and delete products	2025-10-10 20:52:31.322814	3	\N
4	Reports	view_reports	View sales and analytics reports	2025-10-10 20:52:31.322814	4	\N
5	Users & Roles	manage_users	Create and assign users and roles	2025-10-10 20:52:31.322814	5	\N
6	Sales List	sales_list	View Sales List	2025-10-10 20:52:31.322814	15	\N
7	Daily Sales	view_daily_sales	View daily sales	2025-10-10 20:52:31.322814	19	\N
8	Montly Sales	monthly_sales	Track and manage sales	2025-10-10 20:52:31.322814	20	\N
10	Manage Users & Roles	manage_users_roles	Manage Users & Roles	2025-10-23 19:54:06.710505	21	\N
11	Inventory List	inventory_list	Inventory list	2025-10-23 19:56:08.788091	23	\N
12	Sales Dashboard	sales_dashboard	Sales Dashboard	2025-10-23 19:57:02.956943	26	\N
9	Sales POS	sales_pos	Perform POS Sales	2025-10-23 18:58:01.734221	2	2025-10-23 19:03:27.051472
\.


--
-- Data for Name: usr_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usr_roles (id, name, description, is_default, created_at) FROM stdin;
1	Admin	System Administrator	t	2025-10-10 20:45:56.328591
2	Cashier	Handles sales transactions	f	2025-10-10 20:45:56.328591
3	Manager	Oversees sales and inventory	f	2025-10-10 20:45:56.328591
\.


--
-- Data for Name: usr_user_group_mapping; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usr_user_group_mapping (id, user_id, user_group_id, created_on) FROM stdin;
\.


--
-- Data for Name: usr_user_logins; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usr_user_logins (id, user_id, ip_address, logged_in_at, logged_out_at) FROM stdin;
1	1	192.168.1.100	2025-10-11 15:38:18.87297	\N
2	1	127.0.0.1	2025-10-11 22:48:04.570031	\N
3	1	127.0.0.1	2025-10-11 23:21:35.338033	\N
4	1	127.0.0.1	2025-10-11 23:39:02.851334	\N
5	1	127.0.0.1	2025-10-12 00:40:00.097346	\N
6	1	127.0.0.1	2025-10-12 00:57:14.960935	\N
7	1	127.0.0.1	2025-10-12 01:03:16.934422	\N
8	1	127.0.0.1	2025-10-12 01:17:37.557688	\N
9	1	127.0.0.1	2025-10-12 01:19:11.898793	\N
10	1	127.0.0.1	2025-10-12 01:21:43.182499	\N
11	1	127.0.0.1	2025-10-12 01:22:41.353786	\N
12	1	127.0.0.1	2025-10-12 01:23:43.999446	\N
13	1	127.0.0.1	2025-10-12 01:31:15.195546	\N
14	1	127.0.0.1	2025-10-12 11:54:45.035184	\N
15	1	127.0.0.1	2025-10-12 12:20:07.089874	\N
16	1	127.0.0.1	2025-10-12 12:21:59.675688	\N
17	1	127.0.0.1	2025-10-12 13:39:11.108582	\N
18	1	127.0.0.1	2025-10-12 17:03:09.931218	\N
19	1	127.0.0.1	2025-10-13 21:28:44.584219	\N
20	1	127.0.0.1	2025-10-13 22:24:46.885033	\N
21	1	127.0.0.1	2025-10-13 23:32:25.754006	\N
22	1	127.0.0.1	2025-10-14 19:37:40.503799	\N
23	1	127.0.0.1	2025-10-14 22:01:15.02019	\N
24	1	127.0.0.1	2025-10-15 21:40:43.680731	\N
25	1	127.0.0.1	2025-10-16 00:51:11.798415	2025-10-16 08:43:54.905059
26	1	127.0.0.1	2025-10-16 08:44:26.25317	\N
27	1	127.0.0.1	2025-10-17 10:45:02.278697	\N
28	1	127.0.0.1	2025-10-17 22:10:58.208224	2025-10-18 02:53:38.044059
29	2	127.0.0.1	2025-10-18 02:54:01.363146	\N
30	5	127.0.0.1	2025-10-18 15:50:28.55583	2025-10-18 16:29:33.004543
31	6	127.0.0.1	2025-10-18 16:29:49.910468	2025-10-18 17:07:33.970139
32	5	127.0.0.1	2025-10-18 17:07:44.87157	\N
33	5	127.0.0.1	2025-10-18 17:07:56.531053	\N
34	5	127.0.0.1	2025-10-18 17:16:17.6566	\N
35	5	127.0.0.1	2025-10-18 17:19:20.155806	2025-10-19 09:50:49.026803
36	6	127.0.0.1	2025-10-19 09:51:34.254615	\N
37	6	127.0.0.1	2025-10-19 09:51:43.303211	\N
38	6	127.0.0.1	2025-10-19 10:02:18.514443	\N
40	5	127.0.0.1	2025-10-19 10:09:37.021788	\N
41	5	127.0.0.1	2025-10-19 10:13:29.38604	\N
42	5	127.0.0.1	2025-10-19 10:19:07.645599	\N
43	5	127.0.0.1	2025-10-19 10:28:52.837699	\N
44	5	127.0.0.1	2025-10-19 10:44:54.181982	\N
45	5	127.0.0.1	2025-10-19 10:46:00.064514	\N
46	5	127.0.0.1	2025-10-19 13:15:37.173658	\N
47	5	127.0.0.1	2025-10-19 13:37:02.636375	\N
49	5	127.0.0.1	2025-10-19 19:46:07.375967	2025-10-19 21:59:34.223713
51	5	127.0.0.1	2025-10-20 00:45:23.138632	2025-10-20 01:01:16.373747
48	5	127.0.0.1	2025-10-19 15:48:21.642641	2025-10-20 01:01:16.387435
52	5	127.0.0.1	2025-10-20 01:01:44.922526	\N
53	5	127.0.0.1	2025-10-22 20:15:08.840043	2025-10-22 20:34:38.366175
54	5	127.0.0.1	2025-10-22 20:46:53.019228	\N
55	5	127.0.0.1	2025-10-22 20:48:40.356492	2025-10-22 20:50:39.334936
56	5	127.0.0.1	2025-10-22 20:50:48.298153	2025-10-22 20:52:49.115646
57	5	127.0.0.1	2025-10-22 20:53:00.260087	2025-10-22 21:00:59.164324
58	5	127.0.0.1	2025-10-22 21:01:10.296881	2025-10-22 21:29:09.647235
59	6	127.0.0.1	2025-10-22 21:29:22.686086	2025-10-22 22:03:30.259367
50	6	127.0.0.1	2025-10-19 21:59:45.819372	2025-10-22 22:03:30.269682
60	1	127.0.0.1	2025-10-22 22:03:45.884073	2025-10-22 23:17:26.062411
61	6	127.0.0.1	2025-10-22 23:17:42.289506	2025-10-22 23:26:30.831122
39	6	127.0.0.1	2025-10-19 10:09:29.198187	2025-10-22 23:26:30.832423
62	1	127.0.0.1	2025-10-22 23:28:21.523477	2025-10-22 23:50:00.37214
63	6	127.0.0.1	2025-10-22 23:50:15.319939	\N
64	1	127.0.0.1	2025-10-23 09:18:16.175334	2025-10-23 09:37:49.736228
65	2	127.0.0.1	2025-10-23 09:38:05.799731	\N
66	1	127.0.0.1	2025-10-23 18:28:01.224963	2025-10-23 18:30:55.972423
67	2	127.0.0.1	2025-10-23 18:31:14.670465	2025-10-23 19:04:11.073693
68	1	127.0.0.1	2025-10-23 19:04:19.7866	\N
69	1	127.0.0.1	2025-10-23 19:05:01.963446	2025-10-23 20:06:33.514453
70	1	127.0.0.1	2025-10-23 20:06:41.430743	2025-10-23 20:23:26.307809
71	2	127.0.0.1	2025-10-23 20:23:34.905459	2025-10-23 20:35:43.687107
72	1	127.0.0.1	2025-10-23 20:36:15.90007	2025-10-23 20:44:43.594901
73	2	127.0.0.1	2025-10-23 20:44:52.719518	2025-10-23 20:45:48.371163
74	1	127.0.0.1	2025-10-23 20:45:58.31599	2025-10-23 21:02:35.659802
75	2	127.0.0.1	2025-10-23 21:02:45.296196	2025-10-23 21:19:44.655247
76	2	127.0.0.1	2025-10-23 21:19:56.991875	2025-10-23 21:20:19.247817
77	1	127.0.0.1	2025-10-23 21:23:10.242264	2025-10-23 21:23:18.066253
78	2	127.0.0.1	2025-10-23 21:23:48.722848	2025-10-23 21:47:07.837112
79	1	127.0.0.1	2025-10-23 21:47:17.083691	2025-10-23 21:47:41.398886
80	3	127.0.0.1	2025-10-23 21:47:56.760718	2025-10-23 21:49:12.973246
81	1	127.0.0.1	2025-10-23 21:49:29.434658	2025-10-23 21:49:54.366368
82	2	127.0.0.1	2025-10-23 21:50:06.337528	2025-10-23 21:52:42.814879
83	1	127.0.0.1	2025-10-23 21:53:14.947628	\N
84	1	127.0.0.1	2025-10-24 17:42:20.444513	2025-10-24 17:43:41.806347
85	2	127.0.0.1	2025-10-24 17:43:51.023127	2025-10-24 17:44:08.087667
86	3	127.0.0.1	2025-10-24 17:44:20.24308	2025-10-24 18:05:20.146185
87	1	127.0.0.1	2025-10-24 18:05:30.016097	\N
88	1	127.0.0.1	2025-10-25 11:05:35.079233	\N
89	1	127.0.0.1	2025-10-25 11:06:09.312813	\N
90	1	127.0.0.1	2025-10-25 11:07:05.048662	2025-10-25 11:07:13.58356
91	1	127.0.0.1	2025-10-25 12:37:32.716996	\N
\.


--
-- Data for Name: usr_user_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usr_user_roles (id, user_id, role_id, assigned_at) FROM stdin;
1	1	1	2025-10-18 16:27:14.817776
2	2	2	2025-10-18 16:28:02.764254
3	3	3	2025-10-18 16:28:40.295149
\.


--
-- Data for Name: usr_usergroups_navigation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usr_usergroups_navigation (id, usergroup_id, navigation_item_id, can_view, can_create, can_edit, can_delete, created_on) FROM stdin;
\.


--
-- Data for Name: usr_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usr_users (id, name, email, password, is_enabled, created_at, updated_at, remember_token) FROM stdin;
2	Cashier	cashier@vetpos.com	$2y$12$mP2GN1FkZr82IhxmI8mgfe.brhWkpyB5./f82BWFqpA4L9sRb1e3i	t	2025-10-23 09:03:29.129508	2025-10-24 17:44:08.090085	\N
3	Manager	manager@vetpos.com	$2y$12$mP2GN1FkZr82IhxmI8mgfe.brhWkpyB5./f82BWFqpA4L9sRb1e3i	t	2025-10-23 09:04:55.486406	2025-10-24 18:05:20.149054	\N
1	System Admin	admin@vetpos.com	$2y$12$mP2GN1FkZr82IhxmI8mgfe.brhWkpyB5./f82BWFqpA4L9sRb1e3i	t	2025-10-22 22:01:24.908118	2025-10-25 12:37:32.709583	a2ZZQ0IwNjNQQmI0T1pwWENLa0ZpMFdzT2MwejdlU21NM1ZjSFBvN2YyZmRMWnR5
\.


--
-- Data for Name: usr_users_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usr_users_groups (id, name, description, code, is_enabled, created_by, created_on, altered_by, dola, is_super_admin, account_type_id, order_no, institution_type_id, is_default_usergroup, organisation_id, user_group_id) FROM stdin;
1	Admin	Full system access	ADMIN	t	\N	2025-10-18 11:20:53.388534	\N	\N	t	0	\N	0	t	0	\N
2	Cashier	Handles sales and point of sale activities	CASHIER	t	\N	2025-10-18 11:20:53.388534	\N	\N	f	0	\N	0	f	0	\N
3	Manager	Oversees store operations and reporting	MANAGER	t	\N	2025-10-18 11:20:53.388534	\N	\N	f	0	\N	0	f	0	\N
\.


--
-- Data for Name: usr_users_information; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usr_users_information (id, user_id, phone_number, address, gender, dob, profile_photo, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: wf_navigation_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.wf_navigation_items (id, description, is_enabled, parent_id, level, created_by, created_on, altered_by, code, dola, system_interface_id, navigation_type_id, icons_cls, system_label_id, name, order_no, regulatory_function_id, account_type_id, regulatory_subfunction_id, appworkflowstage_category_id, has_appworkflowstage_category, has_initiateapplication_option, nav_routerlink) FROM stdin;
9	Dashboard	t	\N	1	system	2025-10-12 12:52:45.037033	\N	\N	\N	\N	1	fa fa-homefa fa-tachometer-alt	\N	Dashboard	1	\N	\N	\N	\N	f	f	/dashboard
23	Inventory List	t	3	2	system	2025-10-13 23:04:25.793245	\N	\N	\N	\N	\N	fa fa-boxes	\N	Inventory List	\N	\N	\N	\N	\N	f	f	/inventory/list
4	Reports	t	\N	1	system	2025-10-12 12:52:45.037033	\N	\N	\N	\N	1	fa fa-chart-line	\N	Reports	4	\N	\N	\N	\N	f	f	\N
5	Users & Roles	t	\N	1	system	2025-10-12 12:52:45.037033	\N	\N	\N	\N	1	fa fa-users-cog	\N	Users & Roles	5	\N	\N	\N	\N	f	f	\N
2	Sales POS	t	1	2	\N	2025-10-14 21:35:50.893074	\N	\N	\N	\N	1	fa fa-cash-register	\N	Sales POS	1	\N	\N	\N	\N	f	f	/sales
15	Sales List	t	1	2	system	2025-10-12 12:52:45.037033	\N	\N	\N	\N	1	dx-icon-list	\N	Sales List	2	\N	\N	\N	\N	f	f	/sales/list
19	Daily Sales	t	4	2	system	2025-10-12 12:52:45.037033	\N	\N	\N	\N	1	dx-icon-calendar	\N	Daily Sales	2	\N	\N	\N	\N	f	f	/reports/daily
20	Monthly Sales	t	4	2	system	2025-10-12 12:52:45.037033	\N	\N	\N	\N	1	dx-icon-calendar	\N	Monthly Sales	3	\N	\N	\N	\N	f	f	/reports/monthly
3	Inventory	t	\N	1	system	2025-10-12 12:52:45.037033	\N	\N	\N	\N	1	fa fa-icon-box	\N	Inventory	3	\N	\N	\N	\N	f	f	\N
1	Sales	t	\N	1	system	2025-10-12 12:52:45.037033	\N	\N	\N	\N	1	fas fa-shopping-cart	\N	Sales	2	\N	\N	\N	\N	f	f	\N
24	Create Inventory	f	3	2	system	2025-10-13 23:04:25.793245	\N	\N	\N	\N	\N	dx-icon-plus	\N	Create Inventory	\N	\N	\N	\N	\N	f	f	/inventory/create
25	Edit Inventory	f	3	2	system	2025-10-13 23:04:25.793245	\N	\N	\N	\N	\N	dx-icon-edit	\N	Edit Inventory	\N	\N	\N	\N	\N	f	f	/inventory/edit/:id
14	New Sale	f	1	2	system	2025-10-12 12:52:45.037033	\N	\N	\N	\N	1	dx-icon-plus	\N	New Sale	1	\N	\N	\N	\N	f	f	/sales/new
18	Low Stock	f	3	2	system	2025-10-12 12:52:45.037033	\N	\N	\N	\N	1	dx-icon-alert	\N	Low Stock	2	\N	\N	\N	\N	f	f	/inventory/low-stock
16	Top Products	f	1	2	system	2025-10-12 12:52:45.037033	\N	\N	\N	\N	1	dx-icon-star	\N	Top Products	3	\N	\N	\N	\N	f	f	/sales/top-products
26	Sales Dashboard	t	4	2	\N	2025-10-15 23:42:40.863054	\N	\N	\N	\N	1	\N	\N	Sales Dashboard	1	\N	\N	\N	\N	f	f	/reports/dashboard
21	Manage Users & Roles	t	5	2	system	2025-10-12 12:52:45.037033	\N	\N	\N	\N	1	dx-icon-user	\N	Manage Users	1	\N	\N	\N	\N	f	f	/users-roles
\.


--
-- Data for Name: wf_navigation_levels; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.wf_navigation_levels (id, name, description, code, is_enabled, created_by, created_on, altered_by, order_no, navigation_type_id) FROM stdin;
1	Level 1	Top-level menu items	L1	t	\N	2025-10-12 12:49:44.195826	\N	1	1
2	Level 2	Second-level menu items	L2	t	\N	2025-10-12 12:49:44.195826	\N	2	1
3	Level 3	Third-level menu items	L3	t	\N	2025-10-12 12:49:44.195826	\N	3	1
\.


--
-- Data for Name: wf_navigation_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.wf_navigation_permissions (id, user_group_id, navigation_item_id, can_view, can_create, can_edit, can_delete, created_on) FROM stdin;
1	1	2	t	t	t	t	2025-10-18 11:23:34.958555
2	1	9	t	t	t	t	2025-10-18 11:23:34.958555
3	1	23	t	t	t	t	2025-10-18 11:23:34.958555
4	1	4	t	t	t	t	2025-10-18 11:23:34.958555
5	1	5	t	t	t	t	2025-10-18 11:23:34.958555
6	1	15	t	t	t	t	2025-10-18 11:23:34.958555
7	1	19	t	t	t	t	2025-10-18 11:23:34.958555
8	1	20	t	t	t	t	2025-10-18 11:23:34.958555
9	1	3	t	t	t	t	2025-10-18 11:23:34.958555
10	1	1	t	t	t	t	2025-10-18 11:23:34.958555
11	1	24	t	t	t	t	2025-10-18 11:23:34.958555
12	1	25	t	t	t	t	2025-10-18 11:23:34.958555
13	1	14	t	t	t	t	2025-10-18 11:23:34.958555
14	1	18	t	t	t	t	2025-10-18 11:23:34.958555
15	1	16	t	t	t	t	2025-10-18 11:23:34.958555
16	1	26	t	t	t	t	2025-10-18 11:23:34.958555
17	1	21	t	t	t	t	2025-10-18 11:23:34.958555
18	3	4	t	f	f	f	2025-10-18 11:23:34.958555
\.


--
-- Data for Name: wf_navigation_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.wf_navigation_types (id, name, description, is_enabled, created_by, created_on, altered_by, code, dola, order_no, iso_acyronym) FROM stdin;
1	Main Menu	Primary admin menu	t	system	2025-10-12 12:49:31.551205	\N	MAIN_MENU	\N	1	\N
2	Main Menu	Main navigation type	t	\N	2025-10-18 11:13:18.4122	\N	MAIN	\N	\N	\N
\.


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: rono_pos
--

SELECT pg_catalog.setval('public.failed_jobs_id_seq', 1, false);


--
-- Name: fin_expense_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fin_expense_categories_id_seq', 5, true);


--
-- Name: fin_expenses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fin_expenses_id_seq', 1, false);


--
-- Name: inv_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.inv_categories_id_seq', 24, true);


--
-- Name: inv_product_units_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.inv_product_units_id_seq', 22, true);


--
-- Name: inv_products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.inv_products_id_seq', 7, true);


--
-- Name: inv_stock_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.inv_stock_history_id_seq', 58, true);


--
-- Name: inv_stock_movements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.inv_stock_movements_id_seq', 1, false);


--
-- Name: inv_suppliers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.inv_suppliers_id_seq', 1, false);


--
-- Name: jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: rono_pos
--

SELECT pg_catalog.setval('public.jobs_id_seq', 1, false);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: rono_pos
--

SELECT pg_catalog.setval('public.migrations_id_seq', 5, true);


--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: rono_pos
--

SELECT pg_catalog.setval('public.personal_access_tokens_id_seq', 1, false);


--
-- Name: pos_customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pos_customers_id_seq', 1, false);


--
-- Name: pos_sale_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pos_sale_items_id_seq', 25, true);


--
-- Name: pos_sales_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pos_sales_id_seq', 31, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: rono_pos
--

SELECT pg_catalog.setval('public.users_id_seq', 1, false);


--
-- Name: usr_failed_logins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usr_failed_logins_id_seq', 9, true);


--
-- Name: usr_permission_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usr_permission_role_id_seq', 27, true);


--
-- Name: usr_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usr_permissions_id_seq', 12, true);


--
-- Name: usr_roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usr_roles_id_seq', 3, true);


--
-- Name: usr_user_group_mapping_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usr_user_group_mapping_id_seq', 1, false);


--
-- Name: usr_user_logins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usr_user_logins_id_seq', 91, true);


--
-- Name: usr_user_roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usr_user_roles_id_seq', 3, true);


--
-- Name: usr_usergroups_navigation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usr_usergroups_navigation_id_seq', 1, false);


--
-- Name: usr_users_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usr_users_groups_id_seq', 3, true);


--
-- Name: usr_users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usr_users_id_seq', 8, true);


--
-- Name: usr_users_information_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usr_users_information_id_seq', 1, false);


--
-- Name: wf_navigation_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.wf_navigation_items_id_seq', 27, true);


--
-- Name: wf_navigation_levels_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.wf_navigation_levels_id_seq', 7, true);


--
-- Name: wf_navigation_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.wf_navigation_permissions_id_seq', 18, true);


--
-- Name: wf_navigation_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.wf_navigation_types_id_seq', 2, true);


--
-- Name: cache_locks cache_locks_pkey; Type: CONSTRAINT; Schema: public; Owner: rono_pos
--

ALTER TABLE ONLY public.cache_locks
    ADD CONSTRAINT cache_locks_pkey PRIMARY KEY (key);


--
-- Name: cache cache_pkey; Type: CONSTRAINT; Schema: public; Owner: rono_pos
--

ALTER TABLE ONLY public.cache
    ADD CONSTRAINT cache_pkey PRIMARY KEY (key);


--
-- Name: failed_jobs failed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: rono_pos
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs failed_jobs_uuid_unique; Type: CONSTRAINT; Schema: public; Owner: rono_pos
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_uuid_unique UNIQUE (uuid);


--
-- Name: fin_expense_categories fin_expense_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fin_expense_categories
    ADD CONSTRAINT fin_expense_categories_pkey PRIMARY KEY (id);


--
-- Name: fin_expenses fin_expenses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fin_expenses
    ADD CONSTRAINT fin_expenses_pkey PRIMARY KEY (id);


--
-- Name: inv_categories inv_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inv_categories
    ADD CONSTRAINT inv_categories_pkey PRIMARY KEY (id);


--
-- Name: inv_product_units inv_product_units_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inv_product_units
    ADD CONSTRAINT inv_product_units_pkey PRIMARY KEY (id);


--
-- Name: inv_products inv_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inv_products
    ADD CONSTRAINT inv_products_pkey PRIMARY KEY (id);


--
-- Name: inv_stock_history inv_stock_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inv_stock_history
    ADD CONSTRAINT inv_stock_history_pkey PRIMARY KEY (id);


--
-- Name: inv_stock_movements inv_stock_movements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inv_stock_movements
    ADD CONSTRAINT inv_stock_movements_pkey PRIMARY KEY (id);


--
-- Name: inv_suppliers inv_suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inv_suppliers
    ADD CONSTRAINT inv_suppliers_pkey PRIMARY KEY (id);


--
-- Name: job_batches job_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: rono_pos
--

ALTER TABLE ONLY public.job_batches
    ADD CONSTRAINT job_batches_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: rono_pos
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: rono_pos
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: rono_pos
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (email);


--
-- Name: personal_access_tokens personal_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: rono_pos
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: personal_access_tokens personal_access_tokens_token_unique; Type: CONSTRAINT; Schema: public; Owner: rono_pos
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_token_unique UNIQUE (token);


--
-- Name: pos_customers pos_customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pos_customers
    ADD CONSTRAINT pos_customers_pkey PRIMARY KEY (id);


--
-- Name: pos_sale_items pos_sale_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pos_sale_items
    ADD CONSTRAINT pos_sale_items_pkey PRIMARY KEY (id);


--
-- Name: pos_sales pos_sales_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pos_sales
    ADD CONSTRAINT pos_sales_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: rono_pos
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: rono_pos
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: rono_pos
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: usr_failed_logins usr_failed_logins_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_failed_logins
    ADD CONSTRAINT usr_failed_logins_pkey PRIMARY KEY (id);


--
-- Name: usr_permission_role usr_permission_role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_permission_role
    ADD CONSTRAINT usr_permission_role_pkey PRIMARY KEY (id);


--
-- Name: usr_permissions usr_permissions_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_permissions
    ADD CONSTRAINT usr_permissions_code_key UNIQUE (code);


--
-- Name: usr_permissions usr_permissions_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_permissions
    ADD CONSTRAINT usr_permissions_name_key UNIQUE (name);


--
-- Name: usr_permissions usr_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_permissions
    ADD CONSTRAINT usr_permissions_pkey PRIMARY KEY (id);


--
-- Name: usr_roles usr_roles_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_roles
    ADD CONSTRAINT usr_roles_name_key UNIQUE (name);


--
-- Name: usr_roles usr_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_roles
    ADD CONSTRAINT usr_roles_pkey PRIMARY KEY (id);


--
-- Name: usr_user_group_mapping usr_user_group_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_user_group_mapping
    ADD CONSTRAINT usr_user_group_mapping_pkey PRIMARY KEY (id);


--
-- Name: usr_user_logins usr_user_logins_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_user_logins
    ADD CONSTRAINT usr_user_logins_pkey PRIMARY KEY (id);


--
-- Name: usr_user_roles usr_user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_user_roles
    ADD CONSTRAINT usr_user_roles_pkey PRIMARY KEY (id);


--
-- Name: usr_usergroups_navigation usr_usergroups_navigation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_usergroups_navigation
    ADD CONSTRAINT usr_usergroups_navigation_pkey PRIMARY KEY (id);


--
-- Name: usr_users usr_users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_users
    ADD CONSTRAINT usr_users_email_key UNIQUE (email);


--
-- Name: usr_users_groups usr_users_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_users_groups
    ADD CONSTRAINT usr_users_groups_pkey PRIMARY KEY (id);


--
-- Name: usr_users_information usr_users_information_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_users_information
    ADD CONSTRAINT usr_users_information_pkey PRIMARY KEY (id);


--
-- Name: usr_users usr_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_users
    ADD CONSTRAINT usr_users_pkey PRIMARY KEY (id);


--
-- Name: wf_navigation_items wf_navigation_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wf_navigation_items
    ADD CONSTRAINT wf_navigation_items_pkey PRIMARY KEY (id);


--
-- Name: wf_navigation_levels wf_navigation_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wf_navigation_levels
    ADD CONSTRAINT wf_navigation_levels_pkey PRIMARY KEY (id);


--
-- Name: wf_navigation_permissions wf_navigation_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wf_navigation_permissions
    ADD CONSTRAINT wf_navigation_permissions_pkey PRIMARY KEY (id);


--
-- Name: wf_navigation_types wf_navigation_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wf_navigation_types
    ADD CONSTRAINT wf_navigation_types_pkey PRIMARY KEY (id);


--
-- Name: idx_expenses_category_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_expenses_category_id ON public.fin_expenses USING btree (category_id);


--
-- Name: idx_inv_stock_history_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_inv_stock_history_product_id ON public.inv_stock_history USING btree (product_id);


--
-- Name: idx_inv_stock_movements_product; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_inv_stock_movements_product ON public.inv_stock_movements USING btree (product_id);


--
-- Name: idx_products_category_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_category_id ON public.inv_products USING btree (category_id);


--
-- Name: idx_products_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_name ON public.inv_products USING btree (name) WITH (fillfactor='100', deduplicate_items='true');


--
-- Name: idx_products_sku; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_sku ON public.inv_products USING btree (sku) WITH (fillfactor='100', deduplicate_items='true');


--
-- Name: idx_products_supplier_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_supplier_id ON public.inv_products USING btree (supplier_id);


--
-- Name: idx_sale_items_sale_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sale_items_sale_id ON public.pos_sale_items USING btree (sale_id);


--
-- Name: idx_sales_customer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sales_customer_id ON public.pos_sales USING btree (customer_id);


--
-- Name: idx_sales_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sales_user_id ON public.pos_sales USING btree (user_id);


--
-- Name: jobs_queue_index; Type: INDEX; Schema: public; Owner: rono_pos
--

CREATE INDEX jobs_queue_index ON public.jobs USING btree (queue);


--
-- Name: personal_access_tokens_expires_at_index; Type: INDEX; Schema: public; Owner: rono_pos
--

CREATE INDEX personal_access_tokens_expires_at_index ON public.personal_access_tokens USING btree (expires_at);


--
-- Name: personal_access_tokens_tokenable_type_tokenable_id_index; Type: INDEX; Schema: public; Owner: rono_pos
--

CREATE INDEX personal_access_tokens_tokenable_type_tokenable_id_index ON public.personal_access_tokens USING btree (tokenable_type, tokenable_id);


--
-- Name: sessions_last_activity_index; Type: INDEX; Schema: public; Owner: rono_pos
--

CREATE INDEX sessions_last_activity_index ON public.sessions USING btree (last_activity);


--
-- Name: sessions_user_id_index; Type: INDEX; Schema: public; Owner: rono_pos
--

CREATE INDEX sessions_user_id_index ON public.sessions USING btree (user_id);


--
-- Name: pos_customers update_customers_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON public.pos_customers FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: fin_expenses update_expenses_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON public.fin_expenses FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: inv_products update_products_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON public.inv_products FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: pos_sales update_sales_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_sales_updated_at BEFORE UPDATE ON public.pos_sales FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: inv_suppliers update_suppliers_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_suppliers_updated_at BEFORE UPDATE ON public.inv_suppliers FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: usr_users update_users_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.usr_users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: fin_expenses fin_expenses_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fin_expenses
    ADD CONSTRAINT fin_expenses_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.fin_expense_categories(id) ON DELETE SET NULL;


--
-- Name: fin_expenses fin_expenses_recorded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fin_expenses
    ADD CONSTRAINT fin_expenses_recorded_by_fkey FOREIGN KEY (recorded_by) REFERENCES public.usr_users(id) ON DELETE SET NULL;


--
-- Name: usr_user_group_mapping fk_group; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_user_group_mapping
    ADD CONSTRAINT fk_group FOREIGN KEY (user_group_id) REFERENCES public.usr_users_groups(id) ON DELETE CASCADE;


--
-- Name: usr_user_group_mapping fk_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_user_group_mapping
    ADD CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES public.usr_users(id) ON DELETE CASCADE;


--
-- Name: inv_products inv_products_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inv_products
    ADD CONSTRAINT inv_products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.inv_categories(id) ON DELETE SET NULL;


--
-- Name: inv_products inv_products_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inv_products
    ADD CONSTRAINT inv_products_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.inv_suppliers(id) ON DELETE SET NULL;


--
-- Name: inv_stock_history inv_stock_history_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inv_stock_history
    ADD CONSTRAINT inv_stock_history_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.inv_products(id) ON DELETE CASCADE;


--
-- Name: inv_stock_movements inv_stock_movements_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inv_stock_movements
    ADD CONSTRAINT inv_stock_movements_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.inv_products(id) ON DELETE CASCADE;


--
-- Name: pos_sale_items pos_sale_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pos_sale_items
    ADD CONSTRAINT pos_sale_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.inv_products(id) ON DELETE SET NULL;


--
-- Name: pos_sale_items pos_sale_items_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pos_sale_items
    ADD CONSTRAINT pos_sale_items_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.pos_sales(id) ON DELETE CASCADE;


--
-- Name: pos_sales pos_sales_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pos_sales
    ADD CONSTRAINT pos_sales_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.pos_customers(id) ON DELETE SET NULL;


--
-- Name: pos_sales pos_sales_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pos_sales
    ADD CONSTRAINT pos_sales_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.usr_users(id) ON DELETE SET NULL;


--
-- Name: usr_permission_role usr_permission_role_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_permission_role
    ADD CONSTRAINT usr_permission_role_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.usr_permissions(id) ON DELETE CASCADE;


--
-- Name: usr_permission_role usr_permission_role_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_permission_role
    ADD CONSTRAINT usr_permission_role_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.usr_roles(id) ON DELETE CASCADE;


--
-- Name: usr_user_roles usr_user_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_user_roles
    ADD CONSTRAINT usr_user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.usr_roles(id) ON DELETE CASCADE;


--
-- Name: usr_user_roles usr_user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_user_roles
    ADD CONSTRAINT usr_user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.usr_users(id) ON DELETE CASCADE;


--
-- Name: usr_users_information usr_users_information_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usr_users_information
    ADD CONSTRAINT usr_users_information_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.usr_users(id) ON DELETE CASCADE;


--
-- Name: wf_navigation_items wf_navigation_items_navigation_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wf_navigation_items
    ADD CONSTRAINT wf_navigation_items_navigation_type_id_fkey FOREIGN KEY (navigation_type_id) REFERENCES public.wf_navigation_types(id);


--
-- Name: wf_navigation_levels wf_navigation_levels_navigation_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wf_navigation_levels
    ADD CONSTRAINT wf_navigation_levels_navigation_type_id_fkey FOREIGN KEY (navigation_type_id) REFERENCES public.wf_navigation_types(id);


--
-- Name: wf_navigation_permissions wf_navigation_permissions_navigation_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wf_navigation_permissions
    ADD CONSTRAINT wf_navigation_permissions_navigation_item_id_fkey FOREIGN KEY (navigation_item_id) REFERENCES public.wf_navigation_items(id) ON DELETE CASCADE;


--
-- Name: wf_navigation_permissions wf_navigation_permissions_user_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wf_navigation_permissions
    ADD CONSTRAINT wf_navigation_permissions_user_group_id_fkey FOREIGN KEY (user_group_id) REFERENCES public.usr_users_groups(id) ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: TABLE fin_expense_categories; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.fin_expense_categories TO rono_pos;


--
-- Name: SEQUENCE fin_expense_categories_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.fin_expense_categories_id_seq TO rono_pos;


--
-- Name: TABLE fin_expenses; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.fin_expenses TO rono_pos;


--
-- Name: SEQUENCE fin_expenses_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.fin_expenses_id_seq TO rono_pos;


--
-- Name: TABLE inv_categories; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.inv_categories TO rono_pos;


--
-- Name: SEQUENCE inv_categories_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.inv_categories_id_seq TO rono_pos;


--
-- Name: TABLE inv_product_units; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.inv_product_units TO rono_pos;


--
-- Name: SEQUENCE inv_product_units_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.inv_product_units_id_seq TO rono_pos;


--
-- Name: TABLE inv_products; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.inv_products TO rono_pos;


--
-- Name: SEQUENCE inv_products_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.inv_products_id_seq TO rono_pos;


--
-- Name: TABLE inv_stock_history; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.inv_stock_history TO rono_pos;


--
-- Name: SEQUENCE inv_stock_history_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.inv_stock_history_id_seq TO rono_pos;


--
-- Name: TABLE inv_stock_movements; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.inv_stock_movements TO rono_pos;


--
-- Name: SEQUENCE inv_stock_movements_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.inv_stock_movements_id_seq TO rono_pos;


--
-- Name: TABLE inv_suppliers; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.inv_suppliers TO rono_pos;


--
-- Name: SEQUENCE inv_suppliers_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.inv_suppliers_id_seq TO rono_pos;


--
-- Name: TABLE pos_customers; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.pos_customers TO rono_pos;


--
-- Name: SEQUENCE pos_customers_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.pos_customers_id_seq TO rono_pos;


--
-- Name: TABLE pos_sale_items; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.pos_sale_items TO rono_pos;


--
-- Name: SEQUENCE pos_sale_items_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.pos_sale_items_id_seq TO rono_pos;


--
-- Name: TABLE pos_sales; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.pos_sales TO rono_pos;


--
-- Name: SEQUENCE pos_sales_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.pos_sales_id_seq TO rono_pos;


--
-- Name: TABLE usr_failed_logins; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.usr_failed_logins TO rono_pos;


--
-- Name: SEQUENCE usr_failed_logins_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.usr_failed_logins_id_seq TO rono_pos;


--
-- Name: TABLE usr_permission_role; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.usr_permission_role TO rono_pos;


--
-- Name: SEQUENCE usr_permission_role_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.usr_permission_role_id_seq TO rono_pos;


--
-- Name: TABLE usr_permissions; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.usr_permissions TO rono_pos;


--
-- Name: SEQUENCE usr_permissions_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.usr_permissions_id_seq TO rono_pos;


--
-- Name: TABLE usr_roles; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.usr_roles TO rono_pos;


--
-- Name: SEQUENCE usr_roles_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.usr_roles_id_seq TO rono_pos;


--
-- Name: TABLE usr_user_group_mapping; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.usr_user_group_mapping TO rono_pos;


--
-- Name: SEQUENCE usr_user_group_mapping_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.usr_user_group_mapping_id_seq TO rono_pos;


--
-- Name: TABLE usr_user_logins; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.usr_user_logins TO rono_pos;


--
-- Name: SEQUENCE usr_user_logins_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.usr_user_logins_id_seq TO rono_pos;


--
-- Name: TABLE usr_user_roles; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.usr_user_roles TO rono_pos;


--
-- Name: SEQUENCE usr_user_roles_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.usr_user_roles_id_seq TO rono_pos;


--
-- Name: TABLE usr_usergroups_navigation; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.usr_usergroups_navigation TO rono_pos;


--
-- Name: SEQUENCE usr_usergroups_navigation_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.usr_usergroups_navigation_id_seq TO rono_pos;


--
-- Name: TABLE usr_users; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.usr_users TO rono_pos;


--
-- Name: TABLE usr_users_groups; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.usr_users_groups TO rono_pos;


--
-- Name: SEQUENCE usr_users_groups_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.usr_users_groups_id_seq TO rono_pos;


--
-- Name: SEQUENCE usr_users_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.usr_users_id_seq TO rono_pos;


--
-- Name: TABLE usr_users_information; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.usr_users_information TO rono_pos;


--
-- Name: SEQUENCE usr_users_information_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.usr_users_information_id_seq TO rono_pos;


--
-- Name: TABLE wf_navigation_items; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.wf_navigation_items TO rono_pos;


--
-- Name: SEQUENCE wf_navigation_items_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.wf_navigation_items_id_seq TO rono_pos;


--
-- Name: TABLE wf_navigation_levels; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.wf_navigation_levels TO rono_pos;


--
-- Name: SEQUENCE wf_navigation_levels_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.wf_navigation_levels_id_seq TO rono_pos;


--
-- Name: TABLE wf_navigation_permissions; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.wf_navigation_permissions TO rono_pos;


--
-- Name: SEQUENCE wf_navigation_permissions_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.wf_navigation_permissions_id_seq TO rono_pos;


--
-- Name: TABLE wf_navigation_types; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.wf_navigation_types TO rono_pos;


--
-- Name: SEQUENCE wf_navigation_types_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.wf_navigation_types_id_seq TO rono_pos;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO rono_pos;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES TO rono_pos;


--
-- PostgreSQL database dump complete
--

\unrestrict wK02ENBYyu8BUGGgCpKDxpAupW0VO2VhKJw6Mer8iyeeswH2tl6YQoJOxpkb84v

