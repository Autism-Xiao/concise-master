--
-- PostgreSQL database dump
--

\restrict CcfwjqNm1IcXT9C6asxqhYaJYKQKk798UPyUjjgYDUfslHoPgR30ls1OA1xGMdc

-- Dumped from database version 16.16 (Debian 16.16-1.pgdg13+1)
-- Dumped by pg_dump version 16.16 (Debian 16.16-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: base_calendar; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.base_calendar (
    id bigint NOT NULL,
    name character varying(50) NOT NULL,
    color character varying(20) DEFAULT '#1890ff'::character varying NOT NULL,
    owner_id character varying(32) NOT NULL,
    is_public boolean DEFAULT false NOT NULL,
    create_time timestamp without time zone,
    update_time timestamp without time zone
);


--
-- Name: COLUMN base_calendar.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_calendar.id IS '主键';


--
-- Name: COLUMN base_calendar.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_calendar.name IS '日历名称';


--
-- Name: COLUMN base_calendar.color; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_calendar.color IS '颜色标识';


--
-- Name: COLUMN base_calendar.owner_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_calendar.owner_id IS '属主用户ID';


--
-- Name: COLUMN base_calendar.is_public; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_calendar.is_public IS '是否公开';


--
-- Name: COLUMN base_calendar.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_calendar.create_time IS '创建时间';


--
-- Name: COLUMN base_calendar.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_calendar.update_time IS '更新时间';


--
-- Name: base_calendar_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.base_calendar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: base_calendar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.base_calendar_id_seq OWNED BY public.base_calendar.id;


--
-- Name: base_schedule_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.base_schedule_event (
    id bigint NOT NULL,
    calendar_id bigint NOT NULL,
    user_id character varying(32) NOT NULL,
    title character varying(200) NOT NULL,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone NOT NULL,
    description character varying(1000),
    category character varying(50),
    remind_type character varying(20) DEFAULT 'SOCKET'::character varying NOT NULL,
    remind_at timestamp without time zone,
    is_reminded boolean DEFAULT false NOT NULL,
    create_time timestamp without time zone,
    update_time timestamp without time zone
);


--
-- Name: COLUMN base_schedule_event.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_schedule_event.id IS '主键';


--
-- Name: COLUMN base_schedule_event.calendar_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_schedule_event.calendar_id IS '所属日历ID';


--
-- Name: COLUMN base_schedule_event.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_schedule_event.user_id IS '创建者用户ID';


--
-- Name: COLUMN base_schedule_event.title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_schedule_event.title IS '日程标题';


--
-- Name: COLUMN base_schedule_event.start_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_schedule_event.start_time IS '开始时间';


--
-- Name: COLUMN base_schedule_event.end_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_schedule_event.end_time IS '结束时间';


--
-- Name: COLUMN base_schedule_event.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_schedule_event.description IS '描述';


--
-- Name: COLUMN base_schedule_event.category; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_schedule_event.category IS '标签';


--
-- Name: COLUMN base_schedule_event.remind_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_schedule_event.remind_type IS '提醒方式';


--
-- Name: COLUMN base_schedule_event.remind_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_schedule_event.remind_at IS '提醒触发时间点';


--
-- Name: COLUMN base_schedule_event.is_reminded; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_schedule_event.is_reminded IS '是否已提醒';


--
-- Name: COLUMN base_schedule_event.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_schedule_event.create_time IS '创建时间';


--
-- Name: COLUMN base_schedule_event.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_schedule_event.update_time IS '更新时间';


--
-- Name: base_schedule_event_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.base_schedule_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: base_schedule_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.base_schedule_event_id_seq OWNED BY public.base_schedule_event.id;


--
-- Name: base_schedule_reminder_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.base_schedule_reminder_log (
    id bigint NOT NULL,
    event_id bigint NOT NULL,
    user_id character varying(32) NOT NULL,
    title character varying(200) NOT NULL,
    message character varying(1000),
    is_read boolean DEFAULT false NOT NULL,
    read_at timestamp without time zone,
    create_time timestamp without time zone
);


--
-- Name: COLUMN base_schedule_reminder_log.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_schedule_reminder_log.id IS '主键';


--
-- Name: COLUMN base_schedule_reminder_log.event_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_schedule_reminder_log.event_id IS '来源日程ID';


--
-- Name: COLUMN base_schedule_reminder_log.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_schedule_reminder_log.user_id IS '接收用户ID';


--
-- Name: COLUMN base_schedule_reminder_log.title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_schedule_reminder_log.title IS '消息标题';


--
-- Name: COLUMN base_schedule_reminder_log.message; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_schedule_reminder_log.message IS '消息内容';


--
-- Name: COLUMN base_schedule_reminder_log.is_read; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_schedule_reminder_log.is_read IS '是否已读';


--
-- Name: COLUMN base_schedule_reminder_log.read_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_schedule_reminder_log.read_at IS '已读时间';


--
-- Name: COLUMN base_schedule_reminder_log.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_schedule_reminder_log.create_time IS '推送时间';


--
-- Name: base_schedule_reminder_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.base_schedule_reminder_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: base_schedule_reminder_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.base_schedule_reminder_log_id_seq OWNED BY public.base_schedule_reminder_log.id;


--
-- Name: biz_order; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.biz_order (
    id integer NOT NULL,
    tenant_id integer DEFAULT 0 NOT NULL,
    title character varying(128) NOT NULL,
    status smallint DEFAULT '1'::smallint,
    amount numeric,
    signed_at timestamp without time zone,
    remark character varying(128),
    create_by character varying(32),
    update_by character varying(32),
    del_flag smallint DEFAULT '0'::smallint NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: COLUMN biz_order.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.biz_order.tenant_id IS '租户ID(0=平台共享)';


--
-- Name: COLUMN biz_order.create_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.biz_order.create_by IS '创建人';


--
-- Name: COLUMN biz_order.update_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.biz_order.update_by IS '更新人';


--
-- Name: COLUMN biz_order.del_flag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.biz_order.del_flag IS '0正常 1已删除';


--
-- Name: COLUMN biz_order.created_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.biz_order.created_at IS '创建时间';


--
-- Name: COLUMN biz_order.updated_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.biz_order.updated_at IS '更新时间';


--
-- Name: biz_order_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.biz_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: biz_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.biz_order_id_seq OWNED BY public.biz_order.id;


--
-- Name: customer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer (
    id integer NOT NULL,
    tenant_id integer DEFAULT 0 NOT NULL,
    name character varying(128) NOT NULL,
    contact character varying(128),
    phone character varying(128),
    level smallint DEFAULT '1'::smallint,
    vip smallint,
    remark character varying(128),
    create_by character varying(32),
    update_by character varying(32),
    del_flag smallint DEFAULT '0'::smallint NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: COLUMN customer.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customer.tenant_id IS '租户ID(0=平台共享)';


--
-- Name: COLUMN customer.create_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customer.create_by IS '创建人';


--
-- Name: COLUMN customer.update_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customer.update_by IS '更新人';


--
-- Name: COLUMN customer.del_flag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customer.del_flag IS '0正常 1已删除';


--
-- Name: COLUMN customer.created_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customer.created_at IS '创建时间';


--
-- Name: COLUMN customer.updated_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customer.updated_at IS '更新时间';


--
-- Name: customer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customer_id_seq OWNED BY public.customer.id;


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    "timestamp" bigint NOT NULL,
    name character varying NOT NULL
);


--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: supplier; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.supplier (
    id integer NOT NULL,
    tenant_id integer DEFAULT 0 NOT NULL,
    name character varying(128) NOT NULL,
    contact character varying(128),
    level smallint DEFAULT '1'::smallint,
    remark character varying(128),
    del_flag smallint DEFAULT '0'::smallint NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: COLUMN supplier.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.supplier.tenant_id IS '租户ID(0=平台共享)';


--
-- Name: COLUMN supplier.del_flag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.supplier.del_flag IS '0正常 1已删除';


--
-- Name: COLUMN supplier.created_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.supplier.created_at IS '创建时间';


--
-- Name: COLUMN supplier.updated_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.supplier.updated_at IS '更新时间';


--
-- Name: supplier_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.supplier_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: supplier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.supplier_id_seq OWNED BY public.supplier.id;


--
-- Name: sys_announcement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_announcement (
    id character varying(32) NOT NULL,
    tenant_id integer DEFAULT 0 NOT NULL,
    titile character varying(100) NOT NULL,
    msg_content text,
    msg_category character varying(10) DEFAULT '1'::character varying NOT NULL,
    msg_type character varying(10),
    priority character varying(255),
    send_status character varying(10) DEFAULT '0'::character varying NOT NULL,
    sender character varying(100),
    send_time timestamp without time zone,
    cancel_time timestamp without time zone,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    user_ids text,
    del_flag character varying(1) DEFAULT '0'::character varying NOT NULL,
    create_by character varying(32),
    create_time timestamp without time zone DEFAULT now() NOT NULL,
    update_by character varying(32),
    update_time timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: COLUMN sys_announcement.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_announcement.id IS '主键id';


--
-- Name: COLUMN sys_announcement.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_announcement.tenant_id IS '租户ID(0=平台共享)';


--
-- Name: COLUMN sys_announcement.titile; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_announcement.titile IS '标题';


--
-- Name: COLUMN sys_announcement.msg_content; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_announcement.msg_content IS '内容';


--
-- Name: COLUMN sys_announcement.msg_category; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_announcement.msg_category IS '消息类型（1通知公告 2系统消息）';


--
-- Name: COLUMN sys_announcement.msg_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_announcement.msg_type IS '通告对象类型（USER指定用户 ALL全体用户）';


--
-- Name: COLUMN sys_announcement.priority; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_announcement.priority IS '优先级（L低 M中 H高）';


--
-- Name: COLUMN sys_announcement.send_status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_announcement.send_status IS '发布状态（0未发布 1已发布 2已撤销）';


--
-- Name: COLUMN sys_announcement.sender; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_announcement.sender IS '发布人';


--
-- Name: COLUMN sys_announcement.send_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_announcement.send_time IS '发布时间';


--
-- Name: COLUMN sys_announcement.cancel_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_announcement.cancel_time IS '撤销时间';


--
-- Name: COLUMN sys_announcement.start_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_announcement.start_time IS '开始时间';


--
-- Name: COLUMN sys_announcement.end_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_announcement.end_time IS '结束时间';


--
-- Name: COLUMN sys_announcement.user_ids; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_announcement.user_ids IS '指定用户';


--
-- Name: COLUMN sys_announcement.del_flag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_announcement.del_flag IS '删除状态（0正常 1已删除）';


--
-- Name: COLUMN sys_announcement.create_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_announcement.create_by IS '创建人';


--
-- Name: COLUMN sys_announcement.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_announcement.create_time IS '创建时间';


--
-- Name: COLUMN sys_announcement.update_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_announcement.update_by IS '更新人';


--
-- Name: COLUMN sys_announcement.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_announcement.update_time IS '更新时间';


--
-- Name: sys_app; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_app (
    id character varying(32) NOT NULL,
    tenant_id integer DEFAULT 0 NOT NULL,
    app_name character varying(64) NOT NULL,
    client_id character varying(64) NOT NULL,
    status character(1) DEFAULT '0'::bpchar NOT NULL,
    scopes text,
    remark character varying(255),
    del_flag character(1) DEFAULT '0'::bpchar NOT NULL,
    create_by character varying(32),
    create_time timestamp(3) without time zone NOT NULL,
    update_time timestamp(3) without time zone
);


--
-- Name: COLUMN sys_app.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_app.id IS '主键id';


--
-- Name: COLUMN sys_app.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_app.tenant_id IS '租户ID(0=平台级)';


--
-- Name: COLUMN sys_app.app_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_app.app_name IS '应用名称';


--
-- Name: COLUMN sys_app.client_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_app.client_id IS '客户端ID(对第三方公开)';


--
-- Name: COLUMN sys_app.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_app.status IS '状态(0启用 1停用)';


--
-- Name: COLUMN sys_app.scopes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_app.scopes IS '授权范围(JSON数组)';


--
-- Name: COLUMN sys_app.remark; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_app.remark IS '备注';


--
-- Name: COLUMN sys_app.del_flag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_app.del_flag IS '删除标志(0存在 1删除)';


--
-- Name: COLUMN sys_app.create_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_app.create_by IS '创建人';


--
-- Name: COLUMN sys_app.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_app.create_time IS '创建时间';


--
-- Name: COLUMN sys_app.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_app.update_time IS '更新时间';


--
-- Name: sys_app_secret; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_app_secret (
    id character varying(32) NOT NULL,
    app_id character varying(32) NOT NULL,
    secret_hash character(64) NOT NULL,
    secret_prefix character varying(12) NOT NULL,
    status character(1) DEFAULT '0'::bpchar NOT NULL,
    last_used_at timestamp(3) without time zone,
    create_time timestamp(3) without time zone NOT NULL
);


--
-- Name: COLUMN sys_app_secret.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_app_secret.id IS '主键id';


--
-- Name: COLUMN sys_app_secret.app_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_app_secret.app_id IS '应用id';


--
-- Name: COLUMN sys_app_secret.secret_hash; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_app_secret.secret_hash IS 'client_secret的sha256哈希';


--
-- Name: COLUMN sys_app_secret.secret_prefix; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_app_secret.secret_prefix IS '密钥前8位明文(识别用)';


--
-- Name: COLUMN sys_app_secret.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_app_secret.status IS '状态(0有效 1撤销)';


--
-- Name: COLUMN sys_app_secret.last_used_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_app_secret.last_used_at IS '最近一次换取token时间';


--
-- Name: COLUMN sys_app_secret.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_app_secret.create_time IS '创建时间';


--
-- Name: sys_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_config (
    id integer NOT NULL,
    tenant_id integer DEFAULT 0 NOT NULL,
    config_key character varying(128) NOT NULL,
    config_value text,
    value_type character varying(16) DEFAULT 'string'::character varying NOT NULL,
    config_group character varying(64) DEFAULT 'general'::character varying NOT NULL,
    name character varying(128) NOT NULL,
    remark character varying(255),
    is_builtin smallint DEFAULT '0'::smallint NOT NULL,
    allow_tenant smallint DEFAULT '0'::smallint NOT NULL,
    del_flag smallint DEFAULT '0'::smallint NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: COLUMN sys_config.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_config.tenant_id IS '租户ID(0=平台级)';


--
-- Name: COLUMN sys_config.allow_tenant; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_config.allow_tenant IS '租户可覆盖(1=租户可写)';


--
-- Name: sys_config_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sys_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sys_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sys_config_id_seq OWNED BY public.sys_config.id;


--
-- Name: sys_depart; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_depart (
    id character varying(32) NOT NULL,
    parent_id character varying(32),
    depart_name character varying(100) NOT NULL,
    depart_name_en character varying(500),
    depart_name_abbr character varying(500),
    depart_order integer DEFAULT 0 NOT NULL,
    description character varying(500),
    org_category character varying(10) DEFAULT '1'::character varying NOT NULL,
    org_code character varying(64) NOT NULL,
    status character varying(1) DEFAULT '1'::character varying NOT NULL,
    del_flag character varying(1) DEFAULT '0'::character varying NOT NULL,
    create_by character varying(32),
    create_time timestamp without time zone,
    update_by character varying(32),
    update_time timestamp without time zone,
    tenant_id integer DEFAULT 0 NOT NULL
);


--
-- Name: COLUMN sys_depart.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_depart.id IS 'ID';


--
-- Name: COLUMN sys_depart.parent_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_depart.parent_id IS '父机构ID';


--
-- Name: COLUMN sys_depart.depart_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_depart.depart_name IS '机构/部门名称';


--
-- Name: COLUMN sys_depart.depart_name_en; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_depart.depart_name_en IS '英文名';


--
-- Name: COLUMN sys_depart.depart_name_abbr; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_depart.depart_name_abbr IS '缩写';


--
-- Name: COLUMN sys_depart.depart_order; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_depart.depart_order IS '排序';


--
-- Name: COLUMN sys_depart.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_depart.description IS '描述';


--
-- Name: COLUMN sys_depart.org_category; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_depart.org_category IS '机构类别 1公司，2部门，3岗位，4子公司';


--
-- Name: COLUMN sys_depart.org_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_depart.org_code IS '机构编码（唯一性由联合键 (tenant_id, org_code) 保证）';


--
-- Name: COLUMN sys_depart.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_depart.status IS '状态（1启用，0不启用）';


--
-- Name: COLUMN sys_depart.del_flag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_depart.del_flag IS '删除状态（0，正常，1已删除）';


--
-- Name: COLUMN sys_depart.create_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_depart.create_by IS '创建人';


--
-- Name: COLUMN sys_depart.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_depart.create_time IS '创建日期';


--
-- Name: COLUMN sys_depart.update_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_depart.update_by IS '更新人';


--
-- Name: COLUMN sys_depart.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_depart.update_time IS '更新日期';


--
-- Name: COLUMN sys_depart.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_depart.tenant_id IS '租户ID';


--
-- Name: sys_dict; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_dict (
    id character varying(32) NOT NULL,
    dict_name character varying(100) NOT NULL,
    dict_code character varying(100) NOT NULL,
    description character varying(255),
    del_flag integer DEFAULT 0 NOT NULL,
    type integer DEFAULT 0 NOT NULL,
    create_by character varying(32),
    create_time timestamp without time zone,
    update_by character varying(32),
    update_time timestamp without time zone,
    tenant_id integer DEFAULT 0 NOT NULL
);


--
-- Name: COLUMN sys_dict.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_dict.id IS '主键id';


--
-- Name: COLUMN sys_dict.dict_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_dict.dict_name IS '字典名称';


--
-- Name: COLUMN sys_dict.dict_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_dict.dict_code IS '字典编码（唯一性由联合键 (tenant_id, dict_code) 保证）';


--
-- Name: COLUMN sys_dict.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_dict.description IS '描述';


--
-- Name: COLUMN sys_dict.del_flag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_dict.del_flag IS '删除状态（0正常 1已删除）';


--
-- Name: COLUMN sys_dict.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_dict.type IS '字典类型（0 string / 1 number）';


--
-- Name: COLUMN sys_dict.create_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_dict.create_by IS '创建人';


--
-- Name: COLUMN sys_dict.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_dict.create_time IS '创建时间';


--
-- Name: COLUMN sys_dict.update_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_dict.update_by IS '更新人';


--
-- Name: COLUMN sys_dict.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_dict.update_time IS '更新时间';


--
-- Name: COLUMN sys_dict.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_dict.tenant_id IS '租户ID';


--
-- Name: sys_dict_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_dict_item (
    id character varying(32) NOT NULL,
    dict_id character varying(32) NOT NULL,
    item_text character varying(100) NOT NULL,
    item_value character varying(100) NOT NULL,
    description character varying(255),
    color character varying(16),
    sort_order integer DEFAULT 0 NOT NULL,
    status integer DEFAULT 1 NOT NULL,
    create_by character varying(32),
    create_time timestamp without time zone,
    update_by character varying(32),
    update_time timestamp without time zone,
    tenant_id integer DEFAULT 0 NOT NULL
);


--
-- Name: COLUMN sys_dict_item.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_dict_item.id IS '主键id';


--
-- Name: COLUMN sys_dict_item.dict_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_dict_item.dict_id IS '字典id';


--
-- Name: COLUMN sys_dict_item.item_text; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_dict_item.item_text IS '字典项文本';


--
-- Name: COLUMN sys_dict_item.item_value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_dict_item.item_value IS '字典项值';


--
-- Name: COLUMN sys_dict_item.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_dict_item.description IS '描述';


--
-- Name: COLUMN sys_dict_item.color; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_dict_item.color IS '语义色（为空则纯文本渲染）';


--
-- Name: COLUMN sys_dict_item.sort_order; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_dict_item.sort_order IS '排序';


--
-- Name: COLUMN sys_dict_item.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_dict_item.status IS '状态（1启用 0不启用）';


--
-- Name: COLUMN sys_dict_item.create_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_dict_item.create_by IS '创建人';


--
-- Name: COLUMN sys_dict_item.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_dict_item.create_time IS '创建时间';


--
-- Name: COLUMN sys_dict_item.update_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_dict_item.update_by IS '更新人';


--
-- Name: COLUMN sys_dict_item.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_dict_item.update_time IS '更新时间';


--
-- Name: COLUMN sys_dict_item.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_dict_item.tenant_id IS '租户ID';


--
-- Name: sys_file; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_file (
    id integer NOT NULL,
    tenant_id integer DEFAULT 0 NOT NULL,
    parent_id integer DEFAULT 0 NOT NULL,
    name character varying(255) NOT NULL,
    is_folder smallint DEFAULT '0'::smallint NOT NULL,
    ext character varying(32) DEFAULT ''::character varying NOT NULL,
    mime character varying(120) DEFAULT ''::character varying NOT NULL,
    size bigint DEFAULT '0'::bigint NOT NULL,
    storage_key character varying(255) DEFAULT ''::character varying NOT NULL,
    hash character(64) DEFAULT ''::bpchar NOT NULL,
    owner_id character varying(32) DEFAULT ''::character varying NOT NULL,
    dept_id integer DEFAULT 0 NOT NULL,
    is_starred smallint DEFAULT '0'::smallint NOT NULL,
    is_deleted smallint DEFAULT '0'::smallint NOT NULL,
    deleted_at timestamp without time zone,
    sort_order integer DEFAULT 0 NOT NULL,
    remark character varying(255) DEFAULT ''::character varying NOT NULL,
    create_time timestamp without time zone,
    update_time timestamp without time zone
);


--
-- Name: COLUMN sys_file.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_file.id IS '主键';


--
-- Name: COLUMN sys_file.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_file.tenant_id IS '租户ID(0=平台共享)';


--
-- Name: COLUMN sys_file.parent_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_file.parent_id IS '父目录ID(0=根目录)';


--
-- Name: COLUMN sys_file.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_file.name IS '显示名称';


--
-- Name: COLUMN sys_file.is_folder; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_file.is_folder IS '是否文件夹';


--
-- Name: COLUMN sys_file.ext; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_file.ext IS '扩展名';


--
-- Name: COLUMN sys_file.mime; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_file.mime IS 'MIME 类型';


--
-- Name: COLUMN sys_file.size; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_file.size IS '字节数';


--
-- Name: COLUMN sys_file.storage_key; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_file.storage_key IS '物理相对路径';


--
-- Name: COLUMN sys_file.hash; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_file.hash IS 'sha256';


--
-- Name: COLUMN sys_file.owner_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_file.owner_id IS '所有者用户ID';


--
-- Name: COLUMN sys_file.dept_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_file.dept_id IS '所属部门ID';


--
-- Name: COLUMN sys_file.is_starred; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_file.is_starred IS '是否星标';


--
-- Name: COLUMN sys_file.is_deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_file.is_deleted IS '是否已删除';


--
-- Name: COLUMN sys_file.deleted_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_file.deleted_at IS '删除时间';


--
-- Name: COLUMN sys_file.sort_order; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_file.sort_order IS '排序';


--
-- Name: COLUMN sys_file.remark; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_file.remark IS '备注';


--
-- Name: COLUMN sys_file.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_file.create_time IS '创建时间';


--
-- Name: COLUMN sys_file.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_file.update_time IS '更新时间';


--
-- Name: sys_file_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sys_file_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sys_file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sys_file_id_seq OWNED BY public.sys_file.id;


--
-- Name: sys_level; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_level (
    id character varying(32) NOT NULL,
    level_name character varying(100) NOT NULL,
    level_rank integer DEFAULT 0 NOT NULL,
    status character varying(1) DEFAULT '1'::character varying NOT NULL,
    remark character varying(500),
    create_by character varying(32),
    create_time timestamp without time zone,
    update_by character varying(32),
    update_time timestamp without time zone,
    tenant_id integer DEFAULT 0 NOT NULL
);


--
-- Name: COLUMN sys_level.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_level.id IS '主键id';


--
-- Name: COLUMN sys_level.level_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_level.level_name IS '职级名称（唯一性由联合键 (tenant_id, level_name) 保证）';


--
-- Name: COLUMN sys_level.level_rank; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_level.level_rank IS '等级数值，数字越大级别越高';


--
-- Name: COLUMN sys_level.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_level.status IS '状态（1正常，0停用）';


--
-- Name: COLUMN sys_level.remark; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_level.remark IS '备注';


--
-- Name: COLUMN sys_level.create_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_level.create_by IS '创建人';


--
-- Name: COLUMN sys_level.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_level.create_time IS '创建时间';


--
-- Name: COLUMN sys_level.update_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_level.update_by IS '更新人';


--
-- Name: COLUMN sys_level.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_level.update_time IS '更新时间';


--
-- Name: COLUMN sys_level.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_level.tenant_id IS '租户ID';


--
-- Name: sys_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_log (
    id character varying(32) NOT NULL,
    tenant_id integer DEFAULT 0 NOT NULL,
    is_proxy smallint DEFAULT '0'::smallint NOT NULL,
    job_id character varying(32),
    log_content character varying(1000) NOT NULL,
    log_type integer NOT NULL,
    operate_type integer,
    operate_user_id character varying(32),
    operate_user_name character varying(100) NOT NULL,
    ip character varying(100) NOT NULL,
    status integer NOT NULL,
    cost_time bigint,
    browser character varying(64),
    os character varying(64),
    location character varying(128),
    params text,
    error_msg character varying(500),
    create_by character varying(32),
    create_time timestamp without time zone NOT NULL,
    seq bigint,
    prev_hash character varying(64),
    entry_hash character varying(64)
);


--
-- Name: COLUMN sys_log.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log.id IS '主键id';


--
-- Name: COLUMN sys_log.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log.tenant_id IS '租户ID(0=平台级操作)';


--
-- Name: COLUMN sys_log.is_proxy; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log.is_proxy IS '平台管理员代维标记(1=代维/平台视角操作)';


--
-- Name: COLUMN sys_log.job_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log.job_id IS '定时任务id';


--
-- Name: COLUMN sys_log.log_content; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log.log_content IS '日志内容';


--
-- Name: COLUMN sys_log.log_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log.log_type IS '日志类型（0登录日志，1操作日志）';


--
-- Name: COLUMN sys_log.operate_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log.operate_type IS '操作类型（1查询 2添加 3更新 4删除 5导入 6导出）';


--
-- Name: COLUMN sys_log.operate_user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log.operate_user_id IS '操作人员id';


--
-- Name: COLUMN sys_log.operate_user_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log.operate_user_name IS '操作人员名称';


--
-- Name: COLUMN sys_log.ip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log.ip IS 'IP';


--
-- Name: COLUMN sys_log.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log.status IS '操作状态（0正常，1异常）';


--
-- Name: COLUMN sys_log.cost_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log.cost_time IS '耗时（毫秒）';


--
-- Name: COLUMN sys_log.browser; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log.browser IS '浏览器（UA解析，扩展列）';


--
-- Name: COLUMN sys_log.os; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log.os IS '操作系统（UA解析，扩展列）';


--
-- Name: COLUMN sys_log.location; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log.location IS 'IP归属地（ip2region，扩展列）';


--
-- Name: COLUMN sys_log.params; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log.params IS '请求参数（body+query JSON，扩展列）';


--
-- Name: COLUMN sys_log.error_msg; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log.error_msg IS '错误信息（扩展列）';


--
-- Name: COLUMN sys_log.create_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log.create_by IS '创建人';


--
-- Name: COLUMN sys_log.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log.create_time IS '创建时间';


--
-- Name: sys_log_change; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_log_change (
    id character varying(32) NOT NULL,
    tenant_id integer DEFAULT 0 NOT NULL,
    table_name character varying(64) NOT NULL,
    record_id character varying(64) NOT NULL,
    field character varying(64) NOT NULL,
    field_label character varying(64),
    old_value text,
    new_value text,
    operate_user_id character varying(32),
    create_time timestamp(3) without time zone NOT NULL
);


--
-- Name: COLUMN sys_log_change.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log_change.id IS '主键id';


--
-- Name: COLUMN sys_log_change.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log_change.tenant_id IS '租户ID(0=平台级操作)';


--
-- Name: COLUMN sys_log_change.table_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log_change.table_name IS '表名';


--
-- Name: COLUMN sys_log_change.record_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log_change.record_id IS '记录id';


--
-- Name: COLUMN sys_log_change.field; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log_change.field IS '字段名';


--
-- Name: COLUMN sys_log_change.field_label; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log_change.field_label IS '字段中文名';


--
-- Name: COLUMN sys_log_change.old_value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log_change.old_value IS '改前值';


--
-- Name: COLUMN sys_log_change.new_value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log_change.new_value IS '改后值';


--
-- Name: COLUMN sys_log_change.operate_user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log_change.operate_user_id IS '操作人id';


--
-- Name: COLUMN sys_log_change.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_log_change.create_time IS '变更时间';


--
-- Name: sys_message; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_message (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    title character varying(128) NOT NULL,
    content text NOT NULL,
    msg_type character varying(16) DEFAULT 'send'::character varying NOT NULL,
    sender_id character varying(32),
    tenant_id integer DEFAULT 0 NOT NULL,
    receiver_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: COLUMN sys_message.title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_message.title IS '标题';


--
-- Name: COLUMN sys_message.content; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_message.content IS '正文';


--
-- Name: COLUMN sys_message.msg_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_message.msg_type IS '消息类型：send/system';


--
-- Name: COLUMN sys_message.sender_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_message.sender_id IS '发送人用户ID';


--
-- Name: COLUMN sys_message.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_message.tenant_id IS '租户ID(0=平台共享)';


--
-- Name: COLUMN sys_message.receiver_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_message.receiver_count IS '接收人数';


--
-- Name: COLUMN sys_message.created_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_message.created_at IS '创建时间';


--
-- Name: COLUMN sys_message.updated_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_message.updated_at IS '更新时间';


--
-- Name: sys_message_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_message_user (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    message_id uuid NOT NULL,
    user_id character varying(32) NOT NULL,
    is_read smallint DEFAULT '0'::smallint NOT NULL,
    read_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: COLUMN sys_message_user.message_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_message_user.message_id IS '消息ID';


--
-- Name: COLUMN sys_message_user.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_message_user.user_id IS '接收人用户ID';


--
-- Name: COLUMN sys_message_user.is_read; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_message_user.is_read IS '0未读 1已读';


--
-- Name: COLUMN sys_message_user.read_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_message_user.read_at IS '阅读时间';


--
-- Name: COLUMN sys_message_user.created_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_message_user.created_at IS '创建时间';


--
-- Name: sys_permission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_permission (
    id character varying(32) NOT NULL,
    parent_id character varying(32),
    name character varying(255),
    url character varying(255),
    component character varying(255),
    is_route smallint DEFAULT '1'::smallint NOT NULL,
    component_name character varying(255),
    redirect character varying(255),
    menu_type integer,
    perms character varying(255),
    scope character varying(16) DEFAULT 'tenant'::character varying NOT NULL,
    perms_type character varying(10) DEFAULT '0'::character varying NOT NULL,
    sort_no double precision,
    always_show smallint,
    icon character varying(255),
    is_leaf smallint,
    keep_alive smallint,
    hidden smallint DEFAULT '0'::smallint NOT NULL,
    hide_tab smallint,
    description character varying(255),
    create_by character varying(255),
    create_time timestamp without time zone,
    update_by character varying(255),
    update_time timestamp without time zone,
    del_flag integer DEFAULT 0 NOT NULL,
    rule_flag integer DEFAULT 0 NOT NULL,
    status character varying(2),
    internal_or_external smallint
);


--
-- Name: COLUMN sys_permission.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.id IS '主键id';


--
-- Name: COLUMN sys_permission.parent_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.parent_id IS '父id';


--
-- Name: COLUMN sys_permission.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.name IS '菜单标题';


--
-- Name: COLUMN sys_permission.url; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.url IS '路径';


--
-- Name: COLUMN sys_permission.component; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.component IS '组件';


--
-- Name: COLUMN sys_permission.is_route; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.is_route IS '是否路由菜单: 0:不是  1:是（默认值1）';


--
-- Name: COLUMN sys_permission.component_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.component_name IS '组件名字';


--
-- Name: COLUMN sys_permission.redirect; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.redirect IS '一级菜单跳转地址';


--
-- Name: COLUMN sys_permission.menu_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.menu_type IS '菜单类型(0:一级菜单; 1:子菜单:2:按钮权限)';


--
-- Name: COLUMN sys_permission.perms; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.perms IS '菜单权限编码';


--
-- Name: COLUMN sys_permission.scope; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.scope IS '作用域(platform平台级 tenant租户级)';


--
-- Name: COLUMN sys_permission.perms_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.perms_type IS '权限策略1显示2禁用';


--
-- Name: COLUMN sys_permission.sort_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.sort_no IS '菜单排序';


--
-- Name: COLUMN sys_permission.always_show; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.always_show IS '聚合子路由: 1是0否';


--
-- Name: COLUMN sys_permission.icon; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.icon IS '菜单图标';


--
-- Name: COLUMN sys_permission.is_leaf; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.is_leaf IS '是否叶子节点:    1是0否';


--
-- Name: COLUMN sys_permission.keep_alive; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.keep_alive IS '是否缓存该页面:    1:是   0:不是';


--
-- Name: COLUMN sys_permission.hidden; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.hidden IS '是否隐藏路由: 0否,1是';


--
-- Name: COLUMN sys_permission.hide_tab; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.hide_tab IS '是否隐藏tab: 0否,1是';


--
-- Name: COLUMN sys_permission.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.description IS '描述';


--
-- Name: COLUMN sys_permission.create_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.create_by IS '创建人';


--
-- Name: COLUMN sys_permission.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.create_time IS '创建时间';


--
-- Name: COLUMN sys_permission.update_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.update_by IS '更新人';


--
-- Name: COLUMN sys_permission.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.update_time IS '更新时间';


--
-- Name: COLUMN sys_permission.del_flag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.del_flag IS '删除状态 0正常 1已删除';


--
-- Name: COLUMN sys_permission.rule_flag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.rule_flag IS '是否添加数据权限1是0否';


--
-- Name: COLUMN sys_permission.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.status IS '按钮权限状态(0无效1有效)';


--
-- Name: COLUMN sys_permission.internal_or_external; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.internal_or_external IS '外链菜单打开方式 0/内部打开 1/外部打开';


--
-- Name: sys_position; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_position (
    id character varying(32) NOT NULL,
    post_code character varying(100) NOT NULL,
    post_name character varying(100) NOT NULL,
    post_sort integer DEFAULT 0 NOT NULL,
    dept_id character varying(32),
    status character varying(1) DEFAULT '1'::character varying NOT NULL,
    description character varying(500),
    create_by character varying(32),
    create_time timestamp without time zone,
    update_by character varying(32),
    update_time timestamp without time zone,
    tenant_id integer DEFAULT 0 NOT NULL
);


--
-- Name: COLUMN sys_position.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_position.id IS '主键id';


--
-- Name: COLUMN sys_position.post_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_position.post_code IS '岗位编码（唯一性由联合键 (tenant_id, post_code) 保证）';


--
-- Name: COLUMN sys_position.post_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_position.post_name IS '岗位名称';


--
-- Name: COLUMN sys_position.post_sort; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_position.post_sort IS '排序';


--
-- Name: COLUMN sys_position.dept_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_position.dept_id IS '所属部门ID';


--
-- Name: COLUMN sys_position.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_position.status IS '状态（1正常，0停用）';


--
-- Name: COLUMN sys_position.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_position.description IS '描述';


--
-- Name: COLUMN sys_position.create_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_position.create_by IS '创建人';


--
-- Name: COLUMN sys_position.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_position.create_time IS '创建时间';


--
-- Name: COLUMN sys_position.update_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_position.update_by IS '更新人';


--
-- Name: COLUMN sys_position.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_position.update_time IS '更新时间';


--
-- Name: COLUMN sys_position.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_position.tenant_id IS '租户ID';


--
-- Name: sys_position_role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_position_role (
    id character varying(32) NOT NULL,
    position_id character varying(32) NOT NULL,
    role_id character varying(32) NOT NULL,
    tenant_id integer DEFAULT 0 NOT NULL,
    create_time timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: sys_quartz_job; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_quartz_job (
    id character varying(32) NOT NULL,
    job_class_name character varying(255),
    cron_expression character varying(255),
    parameter character varying(255),
    description character varying(255),
    tenant_id integer DEFAULT 0 NOT NULL,
    status integer DEFAULT 0,
    del_flag integer DEFAULT 0,
    create_by character varying(32),
    create_time timestamp without time zone,
    update_by character varying(32),
    update_time timestamp without time zone
);


--
-- Name: COLUMN sys_quartz_job.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_quartz_job.id IS '主键id';


--
-- Name: COLUMN sys_quartz_job.job_class_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_quartz_job.job_class_name IS '任务类名';


--
-- Name: COLUMN sys_quartz_job.cron_expression; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_quartz_job.cron_expression IS 'cron表达式';


--
-- Name: COLUMN sys_quartz_job.parameter; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_quartz_job.parameter IS '参数';


--
-- Name: COLUMN sys_quartz_job.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_quartz_job.description IS '描述';


--
-- Name: COLUMN sys_quartz_job.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_quartz_job.tenant_id IS '租户ID(0=平台级任务)';


--
-- Name: COLUMN sys_quartz_job.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_quartz_job.status IS '状态（0正常 -1停止）';


--
-- Name: COLUMN sys_quartz_job.del_flag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_quartz_job.del_flag IS '删除状态（0正常 1已删除）';


--
-- Name: COLUMN sys_quartz_job.create_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_quartz_job.create_by IS '创建人';


--
-- Name: COLUMN sys_quartz_job.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_quartz_job.create_time IS '创建时间';


--
-- Name: COLUMN sys_quartz_job.update_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_quartz_job.update_by IS '修改人';


--
-- Name: COLUMN sys_quartz_job.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_quartz_job.update_time IS '修改时间';


--
-- Name: sys_region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_region (
    id bigint NOT NULL,
    area_code character varying(20) NOT NULL,
    city_code character varying(10) DEFAULT ''::character varying NOT NULL,
    parent_code character varying(20) DEFAULT '0'::character varying NOT NULL,
    zip_code character varying(10) DEFAULT ''::character varying NOT NULL,
    level smallint DEFAULT '0'::smallint NOT NULL,
    level_text character varying(10) DEFAULT ''::character varying NOT NULL,
    pid bigint DEFAULT '0'::bigint NOT NULL,
    name character varying(100) NOT NULL,
    short_name character varying(50) DEFAULT ''::character varying NOT NULL,
    full_name character varying(100) DEFAULT ''::character varying NOT NULL,
    pinyin character varying(100) DEFAULT ''::character varying NOT NULL,
    lng character varying(20) DEFAULT ''::character varying NOT NULL,
    lat character varying(20) DEFAULT ''::character varying NOT NULL,
    create_time timestamp without time zone,
    update_time timestamp without time zone
);


--
-- Name: COLUMN sys_region.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_region.id IS '主键';


--
-- Name: COLUMN sys_region.area_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_region.area_code IS '区划代码(唯一)';


--
-- Name: COLUMN sys_region.city_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_region.city_code IS '城市代码(电话区号)';


--
-- Name: COLUMN sys_region.parent_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_region.parent_code IS '上级区划代码(顶级为0)';


--
-- Name: COLUMN sys_region.zip_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_region.zip_code IS '邮政编码';


--
-- Name: COLUMN sys_region.level; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_region.level IS '层级(0省份 1城市 2区县 3街道)';


--
-- Name: COLUMN sys_region.level_text; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_region.level_text IS '层级文本';


--
-- Name: COLUMN sys_region.pid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_region.pid IS '父级ID(冗余,顶级为0)';


--
-- Name: COLUMN sys_region.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_region.name IS '名称';


--
-- Name: COLUMN sys_region.short_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_region.short_name IS '简称';


--
-- Name: COLUMN sys_region.full_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_region.full_name IS '全称';


--
-- Name: COLUMN sys_region.pinyin; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_region.pinyin IS '拼音';


--
-- Name: COLUMN sys_region.lng; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_region.lng IS '经度';


--
-- Name: COLUMN sys_region.lat; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_region.lat IS '纬度';


--
-- Name: COLUMN sys_region.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_region.create_time IS '创建时间';


--
-- Name: COLUMN sys_region.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_region.update_time IS '更新时间';


--
-- Name: sys_region_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sys_region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sys_region_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sys_region_id_seq OWNED BY public.sys_region.id;


--
-- Name: sys_role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_role (
    id character varying(32) NOT NULL,
    role_name character varying(200),
    role_code character varying(100) NOT NULL,
    data_scope smallint DEFAULT '1'::smallint NOT NULL,
    description character varying(255),
    status smallint DEFAULT '1'::smallint NOT NULL,
    create_by character varying(32),
    create_time timestamp without time zone,
    update_by character varying(32),
    update_time timestamp without time zone,
    tenant_id integer DEFAULT 0 NOT NULL,
    is_builtin smallint DEFAULT '0'::smallint NOT NULL
);


--
-- Name: COLUMN sys_role.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_role.id IS '主键id';


--
-- Name: COLUMN sys_role.role_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_role.role_name IS '角色名称';


--
-- Name: COLUMN sys_role.role_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_role.role_code IS '角色编码';


--
-- Name: COLUMN sys_role.data_scope; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_role.data_scope IS '数据范围(1全部 2本部门及以下 3本部门 4仅本人)';


--
-- Name: COLUMN sys_role.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_role.description IS '描述';


--
-- Name: COLUMN sys_role.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_role.status IS '状态(1正常 0停用)';


--
-- Name: COLUMN sys_role.create_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_role.create_by IS '创建人';


--
-- Name: COLUMN sys_role.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_role.create_time IS '创建时间';


--
-- Name: COLUMN sys_role.update_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_role.update_by IS '更新人';


--
-- Name: COLUMN sys_role.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_role.update_time IS '更新时间';


--
-- Name: COLUMN sys_role.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_role.tenant_id IS '租户ID';


--
-- Name: COLUMN sys_role.is_builtin; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_role.is_builtin IS '是否内置角色(1是 0否)';


--
-- Name: sys_role_permission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_role_permission (
    role_id character varying(32) NOT NULL,
    permission_id character varying(32) NOT NULL,
    id character varying(32) DEFAULT ''::character varying NOT NULL,
    data_rule_ids character varying(1000),
    operate_date timestamp without time zone,
    operate_ip character varying(100)
);


--
-- Name: sys_tenant; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_tenant (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    code character varying(64) NOT NULL,
    owner_user_id character varying(32),
    contact character varying(50) DEFAULT ''::character varying NOT NULL,
    phone character varying(30) DEFAULT ''::character varying NOT NULL,
    plan character varying(20) DEFAULT 'standard'::character varying NOT NULL,
    begin_date date,
    expire_at date,
    status smallint DEFAULT '0'::smallint NOT NULL,
    remark character varying(255) DEFAULT ''::character varying NOT NULL,
    del_flag smallint DEFAULT '0'::smallint NOT NULL,
    create_by character varying(32),
    create_time timestamp without time zone,
    update_by character varying(32),
    update_time timestamp without time zone
);


--
-- Name: COLUMN sys_tenant.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_tenant.id IS '主键';


--
-- Name: COLUMN sys_tenant.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_tenant.name IS '租户名称';


--
-- Name: COLUMN sys_tenant.code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_tenant.code IS '租户编码';


--
-- Name: COLUMN sys_tenant.owner_user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_tenant.owner_user_id IS '开通人(自助开通)';


--
-- Name: COLUMN sys_tenant.contact; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_tenant.contact IS '联系人';


--
-- Name: COLUMN sys_tenant.phone; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_tenant.phone IS '联系电话';


--
-- Name: COLUMN sys_tenant.plan; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_tenant.plan IS '套餐';


--
-- Name: COLUMN sys_tenant.begin_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_tenant.begin_date IS '开通日期';


--
-- Name: COLUMN sys_tenant.expire_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_tenant.expire_at IS '到期日期';


--
-- Name: COLUMN sys_tenant.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_tenant.status IS '状态:0正常 1停用';


--
-- Name: COLUMN sys_tenant.remark; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_tenant.remark IS '备注';


--
-- Name: COLUMN sys_tenant.del_flag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_tenant.del_flag IS '删除标记';


--
-- Name: COLUMN sys_tenant.create_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_tenant.create_by IS '创建人';


--
-- Name: COLUMN sys_tenant.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_tenant.create_time IS '创建时间';


--
-- Name: COLUMN sys_tenant.update_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_tenant.update_by IS '更新人';


--
-- Name: COLUMN sys_tenant.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_tenant.update_time IS '更新时间';


--
-- Name: sys_tenant_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sys_tenant_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sys_tenant_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sys_tenant_id_seq OWNED BY public.sys_tenant.id;


--
-- Name: sys_tenant_menu; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_tenant_menu (
    id character varying(32) NOT NULL,
    tenant_id integer NOT NULL,
    permission_id character varying(32) NOT NULL,
    create_time timestamp without time zone
);


--
-- Name: COLUMN sys_tenant_menu.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_tenant_menu.id IS '主键id';


--
-- Name: COLUMN sys_tenant_menu.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_tenant_menu.tenant_id IS '租户ID';


--
-- Name: COLUMN sys_tenant_menu.permission_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_tenant_menu.permission_id IS '菜单ID(sys_permission.id)';


--
-- Name: COLUMN sys_tenant_menu.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_tenant_menu.create_time IS '创建时间';


--
-- Name: sys_tenant_usage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_tenant_usage (
    id integer NOT NULL,
    tenant_id integer DEFAULT 0 NOT NULL,
    metric character varying(64) NOT NULL,
    period character varying(6) NOT NULL,
    value bigint DEFAULT '0'::bigint NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: COLUMN sys_tenant_usage.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_tenant_usage.id IS '主键';


--
-- Name: COLUMN sys_tenant_usage.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_tenant_usage.tenant_id IS '租户ID';


--
-- Name: COLUMN sys_tenant_usage.metric; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_tenant_usage.metric IS '指标名';


--
-- Name: COLUMN sys_tenant_usage.period; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_tenant_usage.period IS '账期 YYYYMM';


--
-- Name: COLUMN sys_tenant_usage.value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_tenant_usage.value IS '累计值';


--
-- Name: COLUMN sys_tenant_usage.updated_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_tenant_usage.updated_at IS '更新时间';


--
-- Name: sys_tenant_usage_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sys_tenant_usage_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sys_tenant_usage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sys_tenant_usage_id_seq OWNED BY public.sys_tenant_usage.id;


--
-- Name: sys_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_user (
    id character varying(32) NOT NULL,
    username character varying(100) NOT NULL,
    realname character varying(100),
    password character varying(255) NOT NULL,
    salt character varying(45),
    avatar character varying(255),
    birthday date,
    bio character varying(255),
    sex smallint,
    email character varying(45),
    phone character varying(45),
    password_expire_at timestamp without time zone,
    must_change_password smallint DEFAULT '0'::smallint NOT NULL,
    totp_secret character varying(64),
    totp_enabled smallint DEFAULT '0'::smallint NOT NULL,
    status smallint,
    del_flag smallint,
    is_platform_admin smallint DEFAULT '0'::smallint NOT NULL,
    is_tenant_admin smallint DEFAULT '0'::smallint NOT NULL,
    vip_level smallint DEFAULT '0'::smallint NOT NULL,
    vip_expire_at timestamp without time zone,
    work_no character varying(100),
    telephone character varying(45),
    create_by character varying(32),
    create_time timestamp without time zone,
    update_by character varying(32),
    update_time timestamp without time zone,
    org_code character varying(64),
    depart_ids character varying(1000),
    level_id character varying(32),
    third_id character varying(100),
    third_type character varying(100),
    activiti_sync smallint,
    user_identity smallint,
    client_id character varying(64),
    login_tenant_id integer,
    bpm_status character varying(2),
    sign_enable smallint,
    sign character varying(500),
    main_dep_post_id character varying(32),
    position_type character varying(32),
    last_pwd_update_time timestamp without time zone,
    sort integer,
    iz_hide_contact character varying(1)
);


--
-- Name: COLUMN sys_user.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.id IS '主键id';


--
-- Name: COLUMN sys_user.username; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.username IS '登录账号';


--
-- Name: COLUMN sys_user.realname; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.realname IS '真实姓名';


--
-- Name: COLUMN sys_user.password; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.password IS '密码';


--
-- Name: COLUMN sys_user.salt; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.salt IS 'md5密码盐';


--
-- Name: COLUMN sys_user.avatar; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.avatar IS '头像';


--
-- Name: COLUMN sys_user.birthday; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.birthday IS '生日';


--
-- Name: COLUMN sys_user.bio; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.bio IS '个人简介';


--
-- Name: COLUMN sys_user.sex; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.sex IS '性别(0-默认未知,1-男,2-女)';


--
-- Name: COLUMN sys_user.email; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.email IS '电子邮件';


--
-- Name: COLUMN sys_user.phone; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.phone IS '电话';


--
-- Name: COLUMN sys_user.password_expire_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.password_expire_at IS '密码过期时间(空=不限制)';


--
-- Name: COLUMN sys_user.must_change_password; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.must_change_password IS '下次登录强制改密(1是 0否)';


--
-- Name: COLUMN sys_user.totp_secret; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.totp_secret IS 'TOTP 密钥(base32, 两步验证)';


--
-- Name: COLUMN sys_user.totp_enabled; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.totp_enabled IS '两步验证(1开 0关)';


--
-- Name: COLUMN sys_user.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.status IS '状态(1-正常,2-冻结)';


--
-- Name: COLUMN sys_user.del_flag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.del_flag IS '删除状态(0-正常,1-已删除)';


--
-- Name: COLUMN sys_user.is_platform_admin; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.is_platform_admin IS '是否平台管理员(1是 0否)';


--
-- Name: COLUMN sys_user.is_tenant_admin; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.is_tenant_admin IS '是否租户管理员(1是 0否)';


--
-- Name: COLUMN sys_user.vip_level; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.vip_level IS '会员等级(0普通 1VIP)';


--
-- Name: COLUMN sys_user.vip_expire_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.vip_expire_at IS 'VIP到期时间(空=永久)';


--
-- Name: COLUMN sys_user.work_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.work_no IS '工号，唯一键';


--
-- Name: COLUMN sys_user.telephone; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.telephone IS '座机号';


--
-- Name: COLUMN sys_user.create_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.create_by IS '创建人';


--
-- Name: COLUMN sys_user.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.create_time IS '创建时间';


--
-- Name: COLUMN sys_user.update_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.update_by IS '更新人';


--
-- Name: COLUMN sys_user.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.update_time IS '更新时间';


--
-- Name: COLUMN sys_user.org_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.org_code IS '登录会话的机构编码';


--
-- Name: COLUMN sys_user.depart_ids; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.depart_ids IS '所属部门id集合';


--
-- Name: COLUMN sys_user.level_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.level_id IS '职级ID(sys_level)';


--
-- Name: sys_user_backup_code; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_user_backup_code (
    id character(36) NOT NULL,
    user_id character varying(32) NOT NULL,
    code_hash character(64) NOT NULL,
    used_at timestamp(6) without time zone,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: sys_user_depart; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_user_depart (
    user_id character varying(32) NOT NULL,
    dep_id character varying(32) NOT NULL,
    "ID" character varying(32) DEFAULT ''::character varying NOT NULL
);


--
-- Name: sys_user_post; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_user_post (
    user_id character varying(32) NOT NULL,
    post_id character varying(32) NOT NULL
);


--
-- Name: sys_user_role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_user_role (
    user_id character varying(32) NOT NULL,
    role_id character varying(32) NOT NULL,
    id character varying(32) DEFAULT ''::character varying NOT NULL,
    tenant_id integer,
    source character varying(16) DEFAULT 'manual'::character varying NOT NULL
);


--
-- Name: sys_user_setting; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_user_setting (
    user_id character varying(32) NOT NULL,
    settings text NOT NULL,
    update_time timestamp without time zone
);


--
-- Name: COLUMN sys_user_setting.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user_setting.user_id IS '用户ID';


--
-- Name: COLUMN sys_user_setting.settings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user_setting.settings IS '设置JSON(白名单裁剪后)';


--
-- Name: COLUMN sys_user_setting.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user_setting.update_time IS '最后修改时间';


--
-- Name: sys_user_supervise_dept; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_user_supervise_dept (
    id character varying(32) NOT NULL,
    user_id character varying(32) NOT NULL,
    dept_id character varying(32) NOT NULL,
    tenant_id integer DEFAULT 0 NOT NULL,
    create_time timestamp(3) without time zone DEFAULT now() NOT NULL
);


--
-- Name: COLUMN sys_user_supervise_dept.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user_supervise_dept.user_id IS '被授权用户ID';


--
-- Name: COLUMN sys_user_supervise_dept.dept_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user_supervise_dept.dept_id IS '管辖部门ID（含展开的子孙部门）';


--
-- Name: COLUMN sys_user_supervise_dept.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user_supervise_dept.tenant_id IS '租户ID(0=平台级)';


--
-- Name: COLUMN sys_user_supervise_dept.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user_supervise_dept.create_time IS '创建时间';


--
-- Name: sys_user_tenant; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_user_tenant (
    id integer NOT NULL,
    user_id character varying(32) NOT NULL,
    tenant_id integer NOT NULL,
    status smallint DEFAULT '0'::smallint NOT NULL,
    create_time timestamp without time zone
);


--
-- Name: COLUMN sys_user_tenant.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user_tenant.id IS '主键';


--
-- Name: COLUMN sys_user_tenant.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user_tenant.user_id IS '用户ID';


--
-- Name: COLUMN sys_user_tenant.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user_tenant.tenant_id IS '租户ID';


--
-- Name: COLUMN sys_user_tenant.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user_tenant.status IS '状态:0正常 1停用';


--
-- Name: COLUMN sys_user_tenant.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user_tenant.create_time IS '创建时间';


--
-- Name: sys_user_tenant_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sys_user_tenant_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sys_user_tenant_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sys_user_tenant_id_seq OWNED BY public.sys_user_tenant.id;


--
-- Name: sys_user_watermark; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_user_watermark (
    user_id character varying(32) NOT NULL,
    enabled smallint,
    enforced smallint DEFAULT '0'::smallint NOT NULL,
    content character varying(200),
    density character varying(16),
    updated_by character varying(32),
    updated_at timestamp without time zone
);


--
-- Name: COLUMN sys_user_watermark.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user_watermark.user_id IS '用户ID';


--
-- Name: COLUMN sys_user_watermark.enabled; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user_watermark.enabled IS '开关(1开 0关 null继承全局)';


--
-- Name: COLUMN sys_user_watermark.enforced; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user_watermark.enforced IS '强管控(0不强制 1强制开 2强制关)';


--
-- Name: COLUMN sys_user_watermark.content; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user_watermark.content IS '自定义内容模板';


--
-- Name: COLUMN sys_user_watermark.density; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user_watermark.density IS '自定义密度';


--
-- Name: COLUMN sys_user_watermark.updated_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user_watermark.updated_by IS '最后修改人';


--
-- Name: COLUMN sys_user_watermark.updated_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user_watermark.updated_at IS '最后修改时间';


--
-- Name: sys_watermark_setting; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_watermark_setting (
    tenant_id integer NOT NULL,
    enabled smallint DEFAULT '1'::smallint NOT NULL,
    mode character varying(16) DEFAULT 'optional'::character varying NOT NULL,
    content character varying(200) DEFAULT '{username}'::character varying NOT NULL,
    density character varying(16) DEFAULT 'default'::character varying NOT NULL,
    opacity smallint DEFAULT '8'::smallint NOT NULL,
    rotate smallint DEFAULT '-22'::smallint NOT NULL,
    font_size smallint DEFAULT '14'::smallint NOT NULL,
    updated_by character varying(32),
    updated_at timestamp without time zone
);


--
-- Name: COLUMN sys_watermark_setting.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_watermark_setting.tenant_id IS '租户ID(0=平台默认)';


--
-- Name: COLUMN sys_watermark_setting.enabled; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_watermark_setting.enabled IS '全局默认开关(1开 0关)';


--
-- Name: COLUMN sys_watermark_setting.mode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_watermark_setting.mode IS '策略(optional/forced/off)';


--
-- Name: COLUMN sys_watermark_setting.content; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_watermark_setting.content IS '默认内容模板';


--
-- Name: COLUMN sys_watermark_setting.density; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_watermark_setting.density IS '默认密度';


--
-- Name: COLUMN sys_watermark_setting.opacity; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_watermark_setting.opacity IS '不透明度百分比';


--
-- Name: COLUMN sys_watermark_setting.rotate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_watermark_setting.rotate IS '倾斜角度';


--
-- Name: COLUMN sys_watermark_setting.font_size; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_watermark_setting.font_size IS '字号px';


--
-- Name: COLUMN sys_watermark_setting.updated_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_watermark_setting.updated_by IS '最后修改人';


--
-- Name: COLUMN sys_watermark_setting.updated_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_watermark_setting.updated_at IS '最后修改时间';


--
-- Name: sys_webhook; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_webhook (
    id character varying(32) NOT NULL,
    tenant_id integer DEFAULT 0 NOT NULL,
    app_id character varying(32),
    event character varying(64) NOT NULL,
    url character varying(500) NOT NULL,
    secret character varying(64) NOT NULL,
    status character(1) DEFAULT '0'::bpchar NOT NULL,
    del_flag character(1) DEFAULT '0'::bpchar NOT NULL,
    create_time timestamp(3) without time zone NOT NULL,
    update_time timestamp(3) without time zone
);


--
-- Name: COLUMN sys_webhook.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_webhook.id IS '主键id';


--
-- Name: COLUMN sys_webhook.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_webhook.tenant_id IS '租户ID(0=平台级)';


--
-- Name: COLUMN sys_webhook.app_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_webhook.app_id IS '所属应用';


--
-- Name: COLUMN sys_webhook.event; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_webhook.event IS '订阅事件';


--
-- Name: COLUMN sys_webhook.url; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_webhook.url IS '回调地址(仅https)';


--
-- Name: COLUMN sys_webhook.secret; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_webhook.secret IS 'HMAC-SHA256签名密钥';


--
-- Name: COLUMN sys_webhook.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_webhook.status IS '状态(0启用 1停用)';


--
-- Name: COLUMN sys_webhook.del_flag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_webhook.del_flag IS '删除标志(0存在 1删除)';


--
-- Name: COLUMN sys_webhook.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_webhook.create_time IS '创建时间';


--
-- Name: COLUMN sys_webhook.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_webhook.update_time IS '更新时间';


--
-- Name: sys_webhook_delivery; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_webhook_delivery (
    id character varying(32) NOT NULL,
    webhook_id character varying(32) NOT NULL,
    event character varying(64) NOT NULL,
    status character(1) NOT NULL,
    attempts integer DEFAULT 1 NOT NULL,
    response_code integer,
    error character varying(500),
    payload text,
    create_time timestamp(3) without time zone NOT NULL
);


--
-- Name: COLUMN sys_webhook_delivery.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_webhook_delivery.id IS '主键id';


--
-- Name: COLUMN sys_webhook_delivery.webhook_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_webhook_delivery.webhook_id IS '订阅id';


--
-- Name: COLUMN sys_webhook_delivery.event; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_webhook_delivery.event IS '事件名';


--
-- Name: COLUMN sys_webhook_delivery.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_webhook_delivery.status IS '投递结果(0成功 1失败)';


--
-- Name: COLUMN sys_webhook_delivery.attempts; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_webhook_delivery.attempts IS '尝试次数';


--
-- Name: COLUMN sys_webhook_delivery.response_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_webhook_delivery.response_code IS '最后一次HTTP状态码';


--
-- Name: COLUMN sys_webhook_delivery.error; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_webhook_delivery.error IS '失败原因';


--
-- Name: COLUMN sys_webhook_delivery.payload; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_webhook_delivery.payload IS '请求体快照';


--
-- Name: COLUMN sys_webhook_delivery.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_webhook_delivery.create_time IS '投递时间';


--
-- Name: task; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task (
    id integer NOT NULL,
    tenant_id integer DEFAULT 0 NOT NULL,
    title character varying(64) NOT NULL,
    description text,
    priority smallint DEFAULT '1'::smallint NOT NULL,
    status smallint DEFAULT '0'::smallint NOT NULL,
    assignee_id character varying(32) DEFAULT '0'::character varying NOT NULL,
    due_date timestamp without time zone,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: COLUMN task.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.task.tenant_id IS '租户ID(0=平台共享)';


--
-- Name: COLUMN task.title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.task.title IS '任务标题';


--
-- Name: COLUMN task.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.task.description IS '任务描述';


--
-- Name: COLUMN task.priority; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.task.priority IS '优先级：0低 1中 2高';


--
-- Name: COLUMN task.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.task.status IS '状态：0待处理 1进行中 2已完成 3已取消';


--
-- Name: COLUMN task.assignee_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.task.assignee_id IS '负责人用户ID，0为未指派';


--
-- Name: COLUMN task.due_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.task.due_date IS '截止时间';


--
-- Name: COLUMN task.created_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.task.created_at IS '创建时间';


--
-- Name: COLUMN task.updated_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.task.updated_at IS '更新时间';


--
-- Name: task_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.task_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.task_id_seq OWNED BY public.task.id;


--
-- Name: tool_storage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tool_storage (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    file_name character varying(200),
    ext_name character varying(32),
    path character varying(255) NOT NULL,
    type character varying(16),
    size character varying(32),
    user_id character varying(32),
    tenant_id integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: COLUMN tool_storage.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tool_storage.name IS '文件名';


--
-- Name: COLUMN tool_storage.file_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tool_storage.file_name IS '真实文件名';


--
-- Name: COLUMN tool_storage.ext_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tool_storage.ext_name IS '扩展名';


--
-- Name: COLUMN tool_storage.path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tool_storage.path IS '访问路径';


--
-- Name: COLUMN tool_storage.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tool_storage.type IS '文件类型';


--
-- Name: COLUMN tool_storage.size; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tool_storage.size IS '文件大小';


--
-- Name: COLUMN tool_storage.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tool_storage.user_id IS '上传用户ID';


--
-- Name: COLUMN tool_storage.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tool_storage.tenant_id IS '租户ID(0=平台共享)';


--
-- Name: COLUMN tool_storage.created_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tool_storage.created_at IS '创建时间';


--
-- Name: COLUMN tool_storage.updated_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tool_storage.updated_at IS '更新时间';


--
-- Name: tool_storage_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tool_storage_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tool_storage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tool_storage_id_seq OWNED BY public.tool_storage.id;


--
-- Name: base_calendar id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_calendar ALTER COLUMN id SET DEFAULT nextval('public.base_calendar_id_seq'::regclass);


--
-- Name: base_schedule_event id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_schedule_event ALTER COLUMN id SET DEFAULT nextval('public.base_schedule_event_id_seq'::regclass);


--
-- Name: base_schedule_reminder_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_schedule_reminder_log ALTER COLUMN id SET DEFAULT nextval('public.base_schedule_reminder_log_id_seq'::regclass);


--
-- Name: biz_order id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.biz_order ALTER COLUMN id SET DEFAULT nextval('public.biz_order_id_seq'::regclass);


--
-- Name: customer id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer ALTER COLUMN id SET DEFAULT nextval('public.customer_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: supplier id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier ALTER COLUMN id SET DEFAULT nextval('public.supplier_id_seq'::regclass);


--
-- Name: sys_config id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_config ALTER COLUMN id SET DEFAULT nextval('public.sys_config_id_seq'::regclass);


--
-- Name: sys_file id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_file ALTER COLUMN id SET DEFAULT nextval('public.sys_file_id_seq'::regclass);


--
-- Name: sys_region id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_region ALTER COLUMN id SET DEFAULT nextval('public.sys_region_id_seq'::regclass);


--
-- Name: sys_tenant id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_tenant ALTER COLUMN id SET DEFAULT nextval('public.sys_tenant_id_seq'::regclass);


--
-- Name: sys_tenant_usage id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_tenant_usage ALTER COLUMN id SET DEFAULT nextval('public.sys_tenant_usage_id_seq'::regclass);


--
-- Name: sys_user_tenant id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_user_tenant ALTER COLUMN id SET DEFAULT nextval('public.sys_user_tenant_id_seq'::regclass);


--
-- Name: task id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task ALTER COLUMN id SET DEFAULT nextval('public.task_id_seq'::regclass);


--
-- Name: tool_storage id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tool_storage ALTER COLUMN id SET DEFAULT nextval('public.tool_storage_id_seq'::regclass);


--
-- Data for Name: base_calendar; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.base_calendar (id, name, color, owner_id, is_public, create_time, update_time) FROM stdin;
\.


--
-- Data for Name: base_schedule_event; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.base_schedule_event (id, calendar_id, user_id, title, start_time, end_time, description, category, remind_type, remind_at, is_reminded, create_time, update_time) FROM stdin;
\.


--
-- Data for Name: base_schedule_reminder_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.base_schedule_reminder_log (id, event_id, user_id, title, message, is_read, read_at, create_time) FROM stdin;
\.


--
-- Data for Name: biz_order; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.biz_order (id, tenant_id, title, status, amount, signed_at, remark, create_by, update_by, del_flag, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: customer; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customer (id, tenant_id, name, contact, phone, level, vip, remark, create_by, update_by, del_flag, created_at, updated_at) FROM stdin;
1	0	客户-小王自己创建	\N	13800000000	1	\N	\N	0c8c4eeb19abc6c501b59287ba5ae9e4	\N	0	2026-11-26 01:03:11.521168	2026-11-26 01:03:11.521168
2	0	客户-技术部张技术创建	\N	13800000001	1	\N	\N	ca81b8e211353133e77bc75b49913d89	\N	0	2026-11-26 01:03:11.521168	2026-11-26 01:03:11.521168
3	0	客户-财务部李财务创建	\N	13800000002	1	\N	\N	41c5e48c0d6d1081bf9f4887f6d47606	\N	0	2026-11-26 01:03:11.521168	2026-11-26 01:03:11.521168
4	0	客户-客服部王客服创建	\N	13800000003	1	\N	\N	0d290dddef2c688b263d34f1dbf3c801	\N	0	2026-11-26 01:03:11.521168	2026-11-26 01:03:11.521168
5	0	客户-市场部赵市场创建	\N	13800000004	1	\N	\N	01bc4b87600d348e591cb18ba87dbcfc	\N	0	2026-11-26 01:03:11.521168	2026-11-26 01:03:11.521168
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.migrations (id, "timestamp", name) FROM stdin;
1	1794080000000	Migration1794080000000
2	1794080000001	Migration1794080000001
3	1794080000002	Migration1794080000002
4	1794080000003	Migration1794080000003
5	1794080000004	Migration1794080000004
6	1795050000000	TrimDeptLegacyColumns1795050000000
\.


--
-- Data for Name: supplier; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.supplier (id, tenant_id, name, contact, level, remark, del_flag, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sys_announcement; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_announcement (id, tenant_id, titile, msg_content, msg_category, msg_type, priority, send_status, sender, send_time, cancel_time, start_time, end_time, user_ids, del_flag, create_by, create_time, update_by, update_time) FROM stdin;
\.


--
-- Data for Name: sys_app; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_app (id, tenant_id, app_name, client_id, status, scopes, remark, del_flag, create_by, create_time, update_time) FROM stdin;
\.


--
-- Data for Name: sys_app_secret; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_app_secret (id, app_id, secret_hash, secret_prefix, status, last_used_at, create_time) FROM stdin;
\.


--
-- Data for Name: sys_config; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_config (id, tenant_id, config_key, config_value, value_type, config_group, name, remark, is_builtin, allow_tenant, del_flag, created_at, updated_at) FROM stdin;
1	0	security.password.minLength	8	number	security	密码最小长度	新建/修改密码时的最少字符数，建议 8~20	1	0	0	2026-11-16 12:50:35.529	2026-11-17 12:30:01
2	0	security.password.requireComplexity	true	boolean	security	密码复杂度	true 时要求大写/小写/数字/符号至少三类	1	0	0	2026-11-16 12:50:35.529	2026-11-16 12:50:35.529
3	0	security.password.expireDays	90	number	security	密码有效期（天）	0 表示永不过期；到期后登录强制改密	1	0	0	2026-11-16 12:50:35.529	2026-11-16 12:50:35.529
4	0	security.password.forceChangeOnFirstLogin	false	boolean	security	首次登录强制改密	管理员重置密码后，用户下次登录必须改密	1	0	0	2026-11-16 12:50:35.529	2026-11-16 12:50:35.529
5	0	security.login.maxFailCount	5	number	security	登录失败锁定阈值	连续失败达到该次数后锁定账号	1	0	0	2026-11-16 12:50:35.529	2026-11-16 12:50:35.529
16	0	ops.backup.keepCount	7	number	ops	备份保留份数	只保留最近 N 份，超出的自动删除；本地磁盘紧张时调小	1	0	0	2026-11-16 13:07:23.55	2026-11-16 13:08:11
17	0	ops.backup.verify	true	boolean	ops	备份后导入校验	true 时每次备份都会在临时库真导入一遍并比对表数（慢 2~3 秒，但能确认备份真能用）	1	0	0	2026-11-16 13:07:23.55	2026-11-16 13:07:23.55
18	0	mail.enabled	false	boolean	mail	邮件发送总开关	关闭时忘记密码等功能退化为 dry-run：邮件不真发，内容留在内存 outbox（GET /v1/mail/outbox 可查）	1	0	0	2026-11-16 13:25:35.903	2026-11-16 13:25:35.903
19	0	mail.from		string	mail	发件人	如「系统通知 <no-reply@example.com>」；留空则用 SMTP 账号兜底	1	0	0	2026-11-16 13:25:35.903	2026-11-16 13:25:35.903
20	0	mail.resetCode.ttlMinutes	5	number	mail	重置密码验证码有效期（分钟）	忘记密码邮件里 6 位验证码的有效时长，建议 5~15	1	0	0	2026-11-16 13:25:35.903	2026-11-16 13:25:35.903
21	0	tenant.ui.themeColor		string	tenant	租户主题色	租户品牌主题色，留空跟随平台默认	1	1	0	2026-11-17 12:29:23	2026-11-17 12:30:17
22	0	tenant.login.welcomeText		string	tenant	登录页欢迎语	展示在本租户登录页的欢迎文案，留空跟随平台默认	1	1	0	2026-11-17 12:29:23	2026-11-17 12:29:23
25	0	tenant.vip.maxTenants	1	number	tenant	VIP 可开通租户数	一个 VIP 账号最多能自助开通几个租户；平台级参数，租户不可改	1	0	0	2026-11-17 12:37:28	2026-11-17 12:41:25
26	0	security.platformAdmin.require2fa	false	boolean	security	平台管理员强制两步验证	开启后未绑定 TOTP 的平台管理员可登录但无法执行平台级操作，需先完成绑定	1	0	0	2026-11-17 19:03:56	2026-11-17 19:06:54
27	0	feature.log.maskSensitive	0	boolean	feature	日志敏感字段脱敏	开启后日志中的 password/token 等字段做掩码（存量行为不变，默认关）	1	1	0	2026-11-26 01:39:37.357169	2026-11-26 01:39:37.357169
28	0	feature.rbac.superviseDept	1	boolean	feature	管辖部门数据权限	ReBAC 监管部门数据权限：部门档用户额外可见所选部门数据（默认开）	1	1	0	2026-11-26 01:39:37.357169	2026-11-26 01:39:37.357169
29	0	feature.auth.rememberMe	1	boolean	feature	记住登录凭证	关闭后不再签发记住凭证，存量凭证换取也会被拒（默认开）	1	1	0	2026-11-26 01:39:37.357169	2026-11-26 01:39:37.357169
30	0	sms.enabled	false	boolean	sms	短信发送总开关	凭证走环境变量 SMS_*	1	0	0	2026-11-26 01:39:37.357169	2026-11-26 01:39:37.357169
31	0	sms.provider	aliyun	string	sms	短信通道	通道选择	1	0	0	2026-11-26 01:39:37.357169	2026-11-26 01:39:37.357169
32	0	tenant.quota.maxUsers	0	number	tenant	用户数配额	0=不限制	1	1	0	2026-11-26 01:39:37.357169	2026-11-26 01:39:37.357169
33	0	tenant.quota.maxStorageMb	0	number	tenant	存储配额(MB)	0=不限制	1	1	0	2026-11-26 01:39:37.357169	2026-11-26 01:39:37.357169
34	0	tenant.quota.apiCalls	0	number	tenant	月度API调用量配额	0=不限制	1	1	0	2026-11-26 01:39:37.357169	2026-11-26 01:39:37.357169
\.


--
-- Data for Name: sys_depart; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_depart (id, parent_id, depart_name, depart_name_en, depart_name_abbr, depart_order, description, org_category, org_code, status, del_flag, create_by, create_time, update_by, update_time, tenant_id) FROM stdin;
af598343d6bd897baa306c5489790bc7	2756c6363bd77819291b0e003c019dd1	总经办	\N	\N	1	决策辅助、文件流转、高层日程	2	GM	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 17:52:22.772	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:33:17.34	0
064719832c25df4ba5f58bfbf8872284	2756c6363bd77819291b0e003c019dd1	人力资源部	\N	\N	2	招聘、薪酬、绩效、培训	2	HR	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 17:54:06.761	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:33:30.851	0
2128fcf7ff6c60920e2294e2b009b5ab	2756c6363bd77819291b0e003c019dd1	行政部	\N	\N	3	前台、办公环境、资产、车辆、接待	2	AMD	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 17:54:26.972	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:33:42.755	0
555f8f0307a3d92dfa3923b58889decb	2756c6363bd77819291b0e003c019dd1	财务部	\N	\N	4	会计核算、资金、报表、税务	2	FIN	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 17:54:55.895	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:34:00.83	0
531503f12d9cdf729d9ce8ae535ca6ab	2756c6363bd77819291b0e003c019dd1	法务部	\N	\N	5	合同审核、合规、纠纷	2	LEGAL	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 17:55:10.152	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:34:15.578	0
1577baeb20661e0ba522c60351c101b2	2756c6363bd77819291b0e003c019dd1	产品部	\N	\N	6	需求、原型、用户体验	2	PROD	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 17:55:32.504	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:34:29.162	0
d3e1489934c2d5d5cf10e4cd614c4404	2756c6363bd77819291b0e003c019dd1	技术部	\N	\N	7	研发、测试、运维	2	TECH	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 17:56:01.161	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:34:45.221	0
5db52b767a1cbd831537d81976df3a95	2756c6363bd77819291b0e003c019dd1	市场部	\N	\N	8	品牌、推广、获客	2	MKT	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 17:56:18.695	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:35:01.465	0
f026194db425743c7cd02d3ed50deb67	2756c6363bd77819291b0e003c019dd1	运营部	\N	\N	10	用户、内容、数据运营	2	OPS	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 17:56:52.638	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:35:39.76	0
fd6753b0084a2074f64f6c3bab3ff032	2756c6363bd77819291b0e003c019dd1	客服部	\N	\N	11	售前咨询、售后支持	2	CS	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 17:57:18.376	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:35:49.489	0
b8453f144534871988e733ffbf2cebf4	064719832c25df4ba5f58bfbf8872284	薪酬绩效组	\N	\N	2	薪资、社保、绩效考核	2	HR_COMP	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:01:25.468	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.551	0
2854ec06659a0c455a77e6f310cc96c0	064719832c25df4ba5f58bfbf8872284	培训组	\N	\N	3	培训、人才培养	2	HR_TRAIN	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:01:46.108	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.579	0
f366f71504c6b1ec8d21b93924f09b0d	064719832c25df4ba5f58bfbf8872284	员工关系组	\N	\N	4	合同、考勤、离职	2	HR_ER	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:02:20.317	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.606	0
fc237c66532784bbc636f47e7542955a	af598343d6bd897baa306c5489790bc7	秘书组	\N	\N	3	高层日程、文书	2	GM_SECRETARY	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:00:29.058	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.63	0
30b6686380c4ad34cfadaaf525b35905	2128fcf7ff6c60920e2294e2b009b5ab	前台接待组	\N	\N	1	来访、收发、办公环境	2	ADM_FRONT	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:02:50.27	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.67	0
32c636f441f362d0ecbd3cfc7173ba70	2128fcf7ff6c60920e2294e2b009b5ab	资产管理组	\N	\N	2	办公用品、固定资产	2	ADM_ASSET	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:03:14.006	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.701	0
128414f99c799b60253d912c371a7616	2128fcf7ff6c60920e2294e2b009b5ab	后勤保障组	\N	\N	3	车辆、食堂、安保、保洁	2	ADM_LOGISTICS	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:03:33.02	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.728	0
8ccf8ae1828c7c9f9b9933ff3590f674	555f8f0307a3d92dfa3923b58889decb	会计组	\N	\N	1	记账、报表、税务申报	2	FIN_ACC	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:03:56.801	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.764	0
ec46d2554ec6745bd25c89eacbf2838f	555f8f0307a3d92dfa3923b58889decb	出纳组	\N	\N	2	收付款、银行、现金	2	FIN_CASH	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:04:18.417	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.776	0
e3c7a43c3bf49f56d6ab700e270e1114	555f8f0307a3d92dfa3923b58889decb	成本组	\N	\N	3	成本核算、预算控制	2	FIN_COST	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:04:46.595	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.787	0
99a0d20e0d987922cf12a549625ad4a6	531503f12d9cdf729d9ce8ae535ca6ab	合同组	\N	\N	1	合同起草审核、归档	2	LEGAL_CONTRACT	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:05:06.711	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.811	0
d29d3723af11ad4111c67ad54fbcffef	531503f12d9cdf729d9ce8ae535ca6ab	合规组	\N	\N	2	法律风险、监管合规	2	LEGAL_COMPLIANCE	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:05:24.355	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.825	0
760de6f8fb3aa4be8e60358dfbf91fec	531503f12d9cdf729d9ce8ae535ca6ab	知识产权组	\N	\N	3	专利、商标、著作权	2	LEGAL_IP	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:05:51.981	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.835	0
eccd62d7565486bec4bf7097af9e02ef	1577baeb20661e0ba522c60351c101b2	产品组	\N	\N	1	需求、原型、PRD	2	PROD_PM	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:06:14.635	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.868	0
d6233d450450a6fee112aa0d5bf5a111	1577baeb20661e0ba522c60351c101b2	设计组	\N	\N	2	UI/UX、视觉	2	PROD_UI	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:06:34.399	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.878	0
4fa21fe679ec8a87f089a3f22302cbbb	1577baeb20661e0ba522c60351c101b2	用研组	\N	\N	3	用户调研、可用性测试	2	PROD_UR	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:06:57.733	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.892	0
d03c1e5fa900c7cc374e215fc5aa03c4	d3e1489934c2d5d5cf10e4cd614c4404	前端组	\N	\N	1	Web/小程序前端	2	TECH_FE	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:07:21.266	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.917	0
b901fdcf1f05ef030a4d8611e34c8884	d3e1489934c2d5d5cf10e4cd614c4404	后端组	\N	\N	2	接口、数据、服务	2	TECH_BE	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:07:37.121	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.937	0
0805397fc9ee27797f78e7f0e517fcdb	d3e1489934c2d5d5cf10e4cd614c4404	测试组	\N	\N	3	功能/自动化测试	2	TECH_QA	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:07:56.82	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.96	0
5be257cef78d16f621e7b86a0d646e0a	d3e1489934c2d5d5cf10e4cd614c4404	运维组	\N	\N	4	部署、监控、故障	2	TECH_OPS	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:08:17.019	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.973	0
1fb4b0372ab1925f031895b23f3440b4	d3e1489934c2d5d5cf10e4cd614c4404	数据组	\N	\N	5	数据仓库、BI	2	TECH_DATA	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:08:38.871	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.995	0
39d47b2eaa34dd6aaf2f4a77ff8b549d	5db52b767a1cbd831537d81976df3a95	品牌组	\N	\N	1	品牌定位、VI、公关	2	MKT_BRAND	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:08:57.646	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:20.035	0
64ebf0a472bdb5fe68c96b693bbd27f4	5db52b767a1cbd831537d81976df3a95	推广组	\N	\N	2	投放、渠道获客	2	MKT_PROMO	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:09:26.314	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:20.056	0
18beed4df928b66aa37e54196b867101	5db52b767a1cbd831537d81976df3a95	内容组	\N	\N	3	文案、新媒体、素材	2	MKT_CONTENT	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:09:49.052	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:20.081	0
4e390600751ce578102a6d3903a7c2e8	5db52b767a1cbd831537d81976df3a95	活动组	\N	\N	4	展会、线上活动	2	MKT_EVENT	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:10:12.433	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:20.108	0
55d28a2e23ee0d540765d6f275c137e1	6cae4d898c1073b39b0b0ddd5364c928	销售一组	\N	\N	1	销售一组	2	SALES_D1	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:10:36.633	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:20.144	0
b92d77cc5bb247bc30ecd8af790219df	6cae4d898c1073b39b0b0ddd5364c928	销售二组	\N	\N	2	销售二组	2	SALES_D2	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:10:54.118	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:20.162	0
2aa12fcceb1e0b9c21e35780242b8884	6cae4d898c1073b39b0b0ddd5364c928	渠道组	\N	\N	3	代理商、合作伙伴	2	SALES_CHANNEL	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:11:15.076	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:20.177	0
5bbd2dc7daee73642b67585ec08c40ef	6cae4d898c1073b39b0b0ddd5364c928	大客户组	\N	\N	4	重点客户维护	2	SALES_KA	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:11:33.092	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:20.199	0
327938411ddc10ff9cf1f30bbee3b797	064719832c25df4ba5f58bfbf8872284	招聘组	\N	\N	1	招聘、面试、入职	2	HR_RECRUIT	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:01:03.197	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.632	0
da5ae3b0afa3a7685e2d62273306b665	f026194db425743c7cd02d3ed50deb67	活动运营	\N	\N	4	促销活动策划	2	OPS_EVENT	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:13:32.739	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:02.136	0
7d1f963d67dfe200572b8a84f6f1afa7	fd6753b0084a2074f64f6c3bab3ff032	售前支持	\N	\N	1	咨询、报价、方案	2	CS_PRE	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:13:52.218	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:02.169	0
38597acb8e812274d601af864c1e6c5a	af598343d6bd897baa306c5489790bc7	督办组	\N	\N	2	决议跟踪、跨部门协调	2	GM_SUPERVISION	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:00:07.916	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.634	0
bdd29ce3d7f07a087f73ee2aced413f2	f026194db425743c7cd02d3ed50deb67	内容运营	\N	\N	2	内容生产、审核	2	OPSA02	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:13.558	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:02.139	0
fad47f8b8a28490abed1f058bf24c164	fd6753b0084a2074f64f6c3bab3ff032	售后支持	\N	\N	2	工单、退换、投诉	2	CS_POST	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:14:08.4	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:02.196	0
2756c6363bd77819291b0e003c019dd1	\N	CAd科技	\N	\N	0	总公司	1	CAKJ	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:29:51.529	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:36:39.984	0
6cae4d898c1073b39b0b0ddd5364c928	2756c6363bd77819291b0e003c019dd1	销售部	\N	\N	9	签单、客户关系、回款	2	SALES	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 17:56:34.411	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:35:19.185	0
94d2d903b59374c16e5244fa9641d8cd	f026194db425743c7cd02d3ed50deb67	数据运营	\N	\N	3	指标、分析、增长实验	2	OPS_DATA	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:13:11.717	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:02.138	0
416253c3de1187227e36288a728eb1e0	af598343d6bd897baa306c5489790bc7	战略组	\N	\N	1	规划、经营分析	2	GM_STRATEGY	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 17:59:47.34	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.633	0
4c5e87295e51cacc865bf92accb55875	f026194db425743c7cd02d3ed50deb67	用户运营	\N	\N	1	拉新、留存、社群	2	OPS_USER	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:11:53.314	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:02.136	0
\.


--
-- Data for Name: sys_dict; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_dict (id, dict_name, dict_code, description, del_flag, type, create_by, create_time, update_by, update_time, tenant_id) FROM stdin;
\.


--
-- Data for Name: sys_dict_item; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_dict_item (id, dict_id, item_text, item_value, description, color, sort_order, status, create_by, create_time, update_by, update_time, tenant_id) FROM stdin;
\.


--
-- Data for Name: sys_file; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_file (id, tenant_id, parent_id, name, is_folder, ext, mime, size, storage_key, hash, owner_id, dept_id, is_starred, is_deleted, deleted_at, sort_order, remark, create_time, update_time) FROM stdin;
\.


--
-- Data for Name: sys_level; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_level (id, level_name, level_rank, status, remark, create_by, create_time, update_by, update_time, tenant_id) FROM stdin;
\.


--
-- Data for Name: sys_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_log (id, tenant_id, is_proxy, job_id, log_content, log_type, operate_type, operate_user_id, operate_user_name, ip, status, cost_time, browser, os, location, params, error_msg, create_by, create_time, seq, prev_hash, entry_hash) FROM stdin;
f5ea98eacd5f1296131b4c10e5831ea5	1	0	\N	请先完成滑块验证	0	\N	\N	admin	127.0.0.1	1	\N	未知浏览器	未知系统	本机	\N	\N	admin	2026-11-25 16:17:58.781	\N	\N	15f71070073db405657acee4c1da99cdb411e7057250142fd954d002a922d259
4375ce5c4ae9ce8ac9229b4ff682a210	1	0	\N	登录成功	0	\N	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	\N	未知浏览器	未知系统	本机	\N	\N	admin	2026-11-25 16:18:23.302	\N	\N	9b772165cab375f0930c41fd5bbf20122f2cc691b645f590122dc6b5cd4ba35c
85e11209ab4569ae26e811aa22ad89a0	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	12	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:19:34.335	\N	\N	7051f2cdd0983bfaf24505cc4c0b2a7c7ad8c93da74ec6119cd52bbf095b5840
7c26bccc4f0c592c2ff8eeb0c66514f5	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:20:34.304	\N	\N	7af1bb7a5103c3b88a9c80f703b4eb8a3426e35bbe7f700830cfe07569d84bf2
0a1038fa482422b523f2721802345951	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:21:34.291	\N	\N	c6e65209a992d896f38466e1b8ab15bfbac77a62bd00ab694612e2f9af021205
24cbe651067eaa2de803bb513076cc88	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:22:34.283	\N	\N	1a444136d378d3d401d1d4d071df0e43897ad40bfa8253404b4534bf0e54e971
c6c3fe2092dac2d7caefe7302cd72e3c	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:23:34.297	\N	\N	5950be3f09063ef32bb42d4c20b72dfc88148428555254b5521f40cbe58f1327
5df1fc4057b5b87b6628f2460941e9a2	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:24:34.281	\N	\N	a8b091d944f8c991ce643efd33eae1cbf70a19dd8ef33cf4dde75bce01fe67c1
a96e1abe0602814a6f8f2b2fcc4fb951	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:25:34.301	\N	\N	d0136d0054908b35665b750b26f0b2e64b50392c09808c5d0566d94024b13462
544d5555da791f887b08f112beb17cb2	1	0	\N	登录成功	0	\N	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	\N	Chrome 157	Windows 10	本机	\N	\N	admin	2026-11-25 16:26:34.104	\N	\N	b707463fdb7ae3d4b04ab0714a5f9979c9bb261f94dba30fb2e16dd14d9171ce
d0257d5e6ea5296dd2c1b8fa5639d78e	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	127	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:26:34.354	\N	\N	5fc677582c3ac0bf20c30d807f0be0fc43af051c89e65ad17e3cdd00bd7c7b3a
8a6879a6cdc265ca2c8e0235fa53e408	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	1	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:26:34.39	\N	\N	79d0e666fc519f1da0b4b98bec28ece4fd7717db1b8041c7b9b2fbc8d8097a2c
229e4f04c6b3b260952e2d995a9d3a65	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:27:34.354	\N	\N	48a6007f316904731a535d3e878f9efe68063246947d5945a265fad4eabb7842
993cdecec6be9f6afe5cc46784cf12f9	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:28:35.292	\N	\N	4364d455307b5b344d7ac7671d13be0dd5d43a952abd09f0514bdb6b3997ba8a
ed9eea079599b24c5197644f34b4a451	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:29:35.282	\N	\N	01ce2f5bf720c0c126fa6fa06e2296ae356871387fa5964c4b9d4f6eccb797fb
11945ec97effaa606b07cfe0423ab966	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	6	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:30:35.284	\N	\N	168c860c861817877e65799c917163252024df96f1b99ec0677f38c7d78f1aab
ef03f63f07d7a977d88794b92a083a73	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:31:35.28	\N	\N	310785a5873f16a03cf14d7974b52ae1b0949fd36c3fa710fe1e89c04bc840b5
4a703e51441bdf2a3c6f1a95d1cf6729	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:32:35.289	\N	\N	d3b0ee587d7fbe95663205c89c16117a10765e4fe90f2e845468fbb0615be37b
40cfcc3a1ff64658c18ef2d8176c3d56	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:34:34.301	\N	\N	9e876d038700c0ecee22ac5c0333de47b0e46f5a4089efa304216a5fb67dca18
be733d6fa2ac1f5472af8000e493699d	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:36:34.298	\N	\N	a73df044fc4e988493123dcd8366687853a3b3b264994018e529da2a051b5a6b
f400cb30b21b708c8e4e46b32838528e	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:38:34.29	\N	\N	1bc49937f50d5a5837077b848f09847ca559d483d2e0f3940392a3b5b6384870
49e8069f66bf8cc2ed5e90b905d4dc30	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	15	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:40:34.307	\N	\N	c405d51ca132b039ea0881badaf55b442dee8a32faf528b477afdd59d3096fdf
976a9ca41940e53d85485c8768007c8f	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:42:34.295	\N	\N	22cdd8b084eab6843a309039125a2197dde0c97870dba0f63e7f942e89881550
ba40c0becd5901285016eee0c2c59f0a	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:44:34.296	\N	\N	1b49059f08f40cf8aebb0a03a93372df53d9bbe49e494c58d7f255ce9f114aea
e187c167f15aa5a362a4b14a5a94a18b	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:46:34.287	\N	\N	f6b51372759390acf45a1494c95ed791c003e664427c7873ddc1871b1fd50917
210067c3771a664e72a7c0e3f05769db	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:48:34.308	\N	\N	86f4e68b99b026c18340cf09164d90b14941f20a9d03c08155ea46c1ec521c98
a6bc4767d7317ece036106bb7e981395	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:50:34.287	\N	\N	a3c78309ae68d6af342fa891359a4b7aad435ee47016130367f6f3a87d269ac9
56a60fa04f36c04bff85b81aed74f5a4	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:52:34.305	\N	\N	f5231e333b7af72f688a44b59bdd5e9aab6ae79e7e6f19a6a57214a4cee1cbb1
18c7516bc0dd31e8604faf0ba8e2545e	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	20	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:59:20.449	\N	\N	0f0f9db5d9ec66aa2f5c56a236f00e34c2438978a3549845e2712924ffc3286a
9ebe37d86a7818b1a1b3293552aee2f8	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	5	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:59:20.527	\N	\N	6d18a1a9f71e80e81b55e3e5b1cedd86eb1a0ce4466d5cbe097dcc50a3859c01
43b309dcaa6ee7a163e984f63f03b7f0	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/files	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	4	\N	\N	\N	{"query":{"page":"1","pageSize":"20"}}	\N	admin	2026-11-25 16:59:28.089	\N	\N	9eb06be15577994133bb2536bcb42f57ccda47a5a769c84da34bd3ac7572b42c
c39e88a4fec86e4abd6dd374466ac9b5	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/files/breadcrumb	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	1	\N	\N	\N	{"query":{"folderId":"0"}}	\N	admin	2026-11-25 16:59:28.109	\N	\N	1e149b2626d0852394faf481b8148983fc601fd6b5d81d7aa55fd65c16584588
1561fe87564c0031960316e0632d8bb4	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/files	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	4	\N	\N	\N	{"query":{"page":"1","pageSize":"20"}}	\N	admin	2026-11-25 16:59:28.111	\N	\N	c3f3a395daf20f4927732489ddc93c69547bdc8e5ef3de112ed91f4ab64c8fca
50a563ad87ce8ce79eaf7d89b4f5e5a1	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/files/breadcrumb	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	0	\N	\N	\N	{"query":{"folderId":"0"}}	\N	admin	2026-11-25 16:59:28.244	\N	\N	36a74b2549ef666299c278ad21ba81ff90b1ffd2c0fb08b51570be7ce6644104
e44ba0a7377e4e58f98e37f899924f25	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/files/stats	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	4	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:59:28.112	\N	\N	57c6c1365620ee2b40462032b7be4ce26ffc2fd5acd69cbfd19861befb02891d
860054d8a74069fc84e89c05ab0d9bc0	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/files/stats	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	3	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 16:59:28.356	\N	\N	65f7b7379f16decca4022d0a9d5f48b2714a9644dc933b64b765f43680ef9f18
55d126158505a693531c66fccf1b1281	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/files/recent	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	3	\N	\N	\N	{"query":{"limit":"4"}}	\N	admin	2026-11-25 16:59:28.113	\N	\N	d109028657a57d97381a7d159ed85ee3a22320d403465ab36c309d64e3e7f975
1b1d062c5fc0b09880248aa26c46f39c	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/files/recent	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	2	\N	\N	\N	{"query":{"limit":"4"}}	\N	admin	2026-11-25 16:59:28.465	\N	\N	9c420db96ed6565d7968db628bee5ac0fb03ffd8206487c14961a47846ff9219
fc907cb2db6f8e43d33391cfa13f2ed8	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	109	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:00:14.748	\N	\N	2c3c8043daff13c172bcadbafe58105948fc9e2b33b7131b331f5963f49289c0
75471329022e3dbc5da4c98e19d0a6a0	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	3	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:00:14.777	\N	\N	45aaf9d4348566c3c019ca27929fc6cfe8f68f10a4810b54eb1c27c70610a89d
c0c5cc6c07c833f4882e7649249031fd	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/notices	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{"page":"1","pageSize":"10"}}	\N	admin	2026-11-25 17:00:20.841	\N	\N	01856a2870035e88d247849fc9b6572f2a025744f95ad0e949875d7be21a6ac8
73b3d0b800f67c24b9f56a739ea93dec	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/notices	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	1	\N	\N	\N	{"query":{"page":"1","pageSize":"10"}}	\N	admin	2026-11-25 17:00:20.86	\N	\N	58848ca97d19ba62b8c87d7fa2ba812afe616337b61c7d539de19da664a0f654
fdc761a03f0289b1606a8b0c016c5816	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	4	\N	\N	\N	{"query":{"page":"1","pageSize":"20"}}	\N	admin	2026-11-25 17:00:21.985	\N	\N	b3056adac308c866f881a5b870e1ed9a26752995453ba80821b82021794ce92f
14ea90be486cc51fefe5b9d559102f53	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	1	\N	\N	\N	{"query":{"page":"1","pageSize":"20"}}	\N	admin	2026-11-25 17:00:22	\N	\N	c7708c692ea96d5e1090faa6dd582827932ac16e6f443258f9bd1f0be4ad759a
1b725b02df6de834709e557b596d5fc5	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/suppliers	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	4	\N	\N	\N	{"query":{"page":"1","pageSize":"20"}}	\N	admin	2026-11-25 17:00:22.538	\N	\N	8f2d6174202f6784618f2a427ea3ced0372dcf31a3fe9e0f54a149fca15f7817
1a3251535b6d172ba889f1c2e4afdb7f	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/suppliers	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	1	\N	\N	\N	{"query":{"page":"1","pageSize":"20"}}	\N	admin	2026-11-25 17:00:22.555	\N	\N	bd2ed98e2627ee17c1e2bda45411a4dd4f172488a6640a3943ec866369d41795
954d6df7f1c3a963d77f588e0c40d632	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/tasks	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{"page":"1","pageSize":"10"}}	\N	admin	2026-11-25 17:00:23.11	\N	\N	3c255ca99e4dbdd6186ce9e51d18a5438323cad3356bce3e26f2499bde0a51be
93923db0afe80af18748b8f946e80735	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/tasks	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	1	\N	\N	\N	{"query":{"page":"1","pageSize":"10"}}	\N	admin	2026-11-25 17:00:23.127	\N	\N	3c3cfd3376dd157d0942251e9a3307c0c8dc80ab97a8bb89474908e3bc1e01ce
6ea4b2316ec0302339c4ef19b7a95dfc	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/biz_orders	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	3	\N	\N	\N	{"query":{"page":"1","pageSize":"10"}}	\N	admin	2026-11-25 17:00:23.52	\N	\N	db12aa05c129e65402ae88555876613db4c5903dd37a9054b4cb2f31010ecf93
8b68726310762bbb465dfc38d486da4f	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/biz_orders	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	1	\N	\N	\N	{"query":{"page":"1","pageSize":"10"}}	\N	admin	2026-11-25 17:00:23.537	\N	\N	483d59f5b5f344a2cc18ae09adbc0f86e16aa8397e0c721c5b302bf646b294dc
2be3d6ea50e3e312e4dd5adf9e66b883	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/customers	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	5	\N	\N	\N	{"query":{"page":"1","pageSize":"10"}}	\N	admin	2026-11-25 17:00:24.028	\N	\N	1acac4c5f81f16eb104636559a0c272229643149faeebb86b103dff42997d6be
ac95a27cb1156f9dd0142e5795921da5	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/customers	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	2	\N	\N	\N	{"query":{"page":"1","pageSize":"10"}}	\N	admin	2026-11-25 17:00:24.044	\N	\N	1083d6714b97d2efee80a7952bd35211783ea419223c463a3407220f93de12dc
e002cd6b4fa1788e497a24157f5ca070	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/mine	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	5	\N	\N	\N	{"query":{"page":"1","pageSize":"8"}}	\N	admin	2026-11-25 17:00:38.614	\N	\N	a1690bff00cf61d96b25e4ca267b9b85d771ae8fb9a02ff902ac63d6b4a35e8e
2d27b5d4ccbd45d9d02a81a40a593744	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:01:15.285	\N	\N	5937b5464d5a3d18205764244c709e712df4557123e9bedba40b6e3af5c7c7f4
70a419b9a0ef020727fa7aed2ec7bf2b	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:02:15.288	\N	\N	6f729d259642efb561ef99ebe0260530053aefa48a231f5b89bfff338dbad880
aad336a53eeaa701f63f41c2d3394e4e	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	12	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:03:15.38	\N	\N	a367620edb8f9fc0deb4e505752cfbd0ae4f1ef35adc9248ed945291dc7d62d2
b9ab41ac87123a9a0976f390373ddbd0	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:04:15.302	\N	\N	371bf71abfd215ec841836f664af9b9273195c68dac0faa794dc40392bd57421
1e3959615266bee7d9f3a2bce08dbc53	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:05:15.294	\N	\N	7638afb18dd674e3ff1f7f7c56b8bf84b703e70ea11b6f892de0e13baf6f205e
87dabe32dec7ce92d70437f204e83a69	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	11	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:06:15.319	\N	\N	d77ea02d4aca54ab5e845b556f537cc7237abb7265b9814507db819c4bcd9a2a
01efe5376c5f5531325d157085d78c4a	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:07:34.299	\N	\N	ca01a0252504d0ab6a826cf7844e21a04cedcf9ccd3468826265e17dd45f2bf1
d36a465299ca6d332c63957c8bd93b15	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:08:34.333	\N	\N	c5dba2ec9c90bb1ddd88f296c781516b878b582a7b2cf8f46a6f0fc2bd883ded
a82cffe29b760f0fd8cdc35d7e596e6c	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:09:34.305	\N	\N	90b554793d907e76ffc0e8942626fb3d983dace05853c8d1ecc60d8f0ff367b8
2cfec09dc061ebb27eaf29d72e0a7b36	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:10:34.294	\N	\N	b996fbda16828487fc239a01e510b5684e604dfd64f655215b461b8c5277cd49
348e3993ad65835afbc7b7adc1b41131	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:11:34.292	\N	\N	90012d249ed4d1198443730cb193a7a384255e64d4256372e565931136d2de9f
38f6db359540acb4a8121744baa3c344	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:12:34.29	\N	\N	30220f65e5291ff6b283ee84cd5f4c6578452875eb2c6769ab398c20bd5fb00e
4af68fc1983d4bffe1bc72cf7d003443	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:13:34.296	\N	\N	d986b9c5f556c648232cc53b1911c85f80af8734f5300ee05ca0dc8715cbfc77
2cc3012566924cbb633f2ea71f256d61	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:14:34.289	\N	\N	c9fc22d0ba3daeeb90789244065c46cf69c3b3655c423701c1b14379534fbbba
7075bc142812e0edebcc2da3bdb16fee	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:15:34.33	\N	\N	7074a15212b5d3f9a109fc9faea952959ff4cd904dbe4f0d0f306d1b375a146a
21c8875be4343d7d5c36669278783e8c	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:16:34.308	\N	\N	499a82ff47399e0e2820dfd48c77cf5ee61d85ded3ab0524abe9f8cf5a75bef7
adb171f6703aa48e6a2c88af1ee1ce62	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:17:34.318	\N	\N	d67ccd0ed8cf637b0d37f76a18cb78c2dbc4474f9f862d548573b093e5a37152
e9ab3c38899ee7998eee2d573e2a54ce	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:18:34.291	\N	\N	0c6e14a927b03a858522a01fd410ff7f2691b86bbaa3921fea9de9826e27ed0a
9d7838916f3b55ccb130e65c5b6d414f	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:19:34.285	\N	\N	b5411cb1d3f5c5a2b023f3cadf04efae1259470f3f5914d1c1616b656e2c7c8e
7fb1f488d70c6090531940bc468b504f	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:20:34.31	\N	\N	bb5b76e38b697be96a3438b3d79f96088a19b3ca7134dc7988ff5a65b86e64d8
b15604647e8efd89607d147ef15aab2d	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	11	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:21:34.307	\N	\N	bf1b1ea03c6628a9116059b3824857177e6f6dca70990e6d9886cd834a8efd4b
6654df5c371732583facfd8fa167f072	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:22:34.296	\N	\N	681d878ec2a4c323c3a8b98bba6e03c9f8cbdf8638d1b885d6363a07f0e48ca0
348a1da9912d44156dd83c8b81c1f59e	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:23:34.305	\N	\N	c20d08db7e9dc2a2ec9e0d418c12708f71fe61cef9fec27c74fafa878526d03a
e5a03fb3a60e6fdb47d737a3e1ed4c11	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:24:34.289	\N	\N	91125e865b6959b70fe3b8d92b3cfac6f011c4b7de1df644540508d828bb8233
391615241db2426b7b21850ddcacbd3e	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	112	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:24:57.792	\N	\N	76d18e11b6761f7893a81c75e5e25fd575a4d2c7fa3dcd95a3422f658522e5ac
6832c8b3a576902ed667054172688603	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	4	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:24:57.837	\N	\N	872080f059b7a96e9c1d2e356b348131e2678bcb2c51dfd375181cba6e5098c7
e4c0780090f2ddcffcdb936e5c879dff	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:25:58.273	\N	\N	9abbca3b0fe875af5991e28e36d61dd23eb33b182b02d79f0d2feff478091b25
943a43362e2feb9a19f810a082a888db	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:26:58.289	\N	\N	c50c78556f0a34ce3cb1ef7f0a8275fe93cf303b45d86855b2f8de1e3724998c
4e3695af2a59a5cbb877e7abf0757802	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:27:58.305	\N	\N	3473770703bf8a99e489bafdcc795373e74b029f40937ee1137c72b856eea8c6
6ec2fcad9c691590edec7500b9935ef8	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:28:58.322	\N	\N	ad6de69872f0f105b85a9f4a67b6b67f9521d7365e13ffa1a607151f92300632
1d1d044f579fe429e1333b1766bfddd9	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:29:58.303	\N	\N	6870df62e07d519e6974120db3b866de6b51153cf90b20fe03e596e9f90cff70
f328c4c0737befb51cdeea226016417b	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:30:36.275	\N	\N	e31470d2330e89e7bcbf40bfbc3c8683c4c71b101b6057dc88c65c170cad042a
abe2a066541f85a22d3ee32e3ba948d3	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	2	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:30:36.317	\N	\N	b5488654bc003b8b7f0adecb0eda98b920adb8e62dc935e89e97666851167ce8
be3e4e122501863d28b585e5b0a20551	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:31:36.287	\N	\N	ec6c9ec9bd0303d57ff6163f47954f4edbd8eb4665f25a537e587c6a9b701178
b909dfaf4239d4780837452c8d5be164	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:32:36.306	\N	\N	220203c5ad6abd8a02404469cfdbd4f6437ce06717b4e5e69345d99855884062
9eff089549c077233640df1a85a90c82	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	14	\N	\N	\N	{"query":{},"body":{"departName":"总经办","parentId":null,"orgCode":"GM","orgCategory":"2","departOrder":0,"status":"1","description":"General Manager"}}	\N	admin	2026-11-25 17:33:16.216	\N	\N	4e9b380779f23e7e52b47dd6a26d3ca746ad1cc190b2a58079a6f31963ec247d
5fc6f6a6aa788295ae87f910576dafa3	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	85	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:33:36.207	\N	\N	6a70d23db50a27b34bb115f9fb8dcfcbafead6d18929765bd487fe302a5ccb31
14a000a60314f7cd7f096f573ec7e4ea	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{},"body":{"departName":"技术部","parentId":null,"orgCode":"TECH","orgCategory":"2","departOrder":1,"status":"1","description":"研发核心"}}	\N	admin	2026-11-25 17:33:38.35	\N	\N	08d3084a3070330305cdd5208058590b629d1cb10196f514d879428cfb4b2547
6e5902086ed4425d18d5b91b5371c08e	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{},"body":{"departName":"产品部","parentId":null,"orgCode":"PROD","orgCategory":"2","departOrder":2,"status":"1","description":"产品 + 设计"}}	\N	admin	2026-11-25 17:34:03.637	\N	\N	71ba76ecb42bbfadef34da915849001f874c67c35e846038e724fa0f4e37fbe4
6e627d66a835840a4d8b3e4728b969ec	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	11	\N	\N	\N	{"query":{},"body":{"departName":"市场部","parentId":null,"orgCode":"MKT","orgCategory":"2","departOrder":4,"status":"1","description":"品牌推广"}}	\N	admin	2026-11-25 17:34:26.948	\N	\N	fd0fb821ddede44bcbbe71d3e2c2b3aa8e0e06ec38ba289863e0a3fa312f3be1
7ce5ce3d38220e8cd897db2ed75c0082	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:34:36.108	\N	\N	936f204e7bf836cc3a81e438815ca278f707ea219f964d0003f604988db17ec5
0578ad4c4d0584d12e75408f6f47c6b0	0	0	\N	部门管理 - PUT /api/v1/depts/58cfac62e97a7e010be281db024ac135	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	11	\N	\N	\N	{"query":{},"body":{"departName":"市场部","parentId":null,"orgCode":"MKT","orgCategory":"2","departOrder":3,"status":"1","description":"品牌推广"}}	\N	admin	2026-11-25 17:34:50.367	\N	\N	1431ef91777f0766905f6a3e7c6149cd2d9eb5853e9bccb423e279ea221ed575
7aefced9170839762d225f12e6442c9a	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	69	\N	\N	\N	{"query":{},"body":{"departName":"销售部","parentId":null,"orgCode":"SALES","orgCategory":"2","departOrder":4,"status":"1","description":"业务签单"}}	\N	admin	2026-11-25 17:35:22.743	\N	\N	e38c9d0b6023cf6169855b2365d7198868b752e3c6b406a15c812ff7226c86c9
c6f41138a3d5ce62a4c84565f7fdfd11	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	6	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:35:36.231	\N	\N	5e0f8b72d1e856ccb525db27d2163219916cebd7015521f6d12009b89d989ff5
9a6ab13baca5a88d17ca3fed53da912e	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{},"body":{"departName":"运营部","parentId":null,"orgCode":"OPS","orgCategory":"2","departOrder":5,"status":"1","description":"用户/内容/数据"}}	\N	admin	2026-11-25 17:35:48.596	\N	\N	b822657749689266e39f5b886d7b66c0deee07ded0631063103d6ba60cd9fc3c
5d9f33656291a01d79d025607de9302b	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	12	\N	\N	\N	{"query":{},"body":{"departName":"客服部","parentId":null,"orgCode":"CS","orgCategory":"2","departOrder":6,"status":"1","description":"Customer Service"}}	\N	admin	2026-11-25 17:36:08.633	\N	\N	dd5eae494cea0eb9157ad3f8d65f5809b64dfb63ef66d093ad064b67014f1ea5
cf8f70140ad29f496048cec9b96003d1	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	69	\N	\N	\N	{"query":{},"body":{"departName":"人力资源部","parentId":null,"orgCode":"HR","orgCategory":"2","departOrder":7,"status":"1","description":"招聘薪酬"}}	\N	admin	2026-11-25 17:36:28.446	\N	\N	98d1813d7f477bce5e0018d86f58bbf639ebe99c1f4aaea40010896fd5b2c357
4f2ffb7076a8e3a2b45a52485d26ff23	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	55	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:36:36.154	\N	\N	48fd398a39fda99470f3258db2c905c1753794894803a591a2a523275ebe90d3
87a73ace2b8e753e5334b199864b7124	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{},"body":{"departName":"行政部","parentId":null,"orgCode":"ADM","orgCategory":"2","departOrder":8,"status":"1","description":"后勤资产"}}	\N	admin	2026-11-25 17:36:47.844	\N	\N	6cdc1bfaa1887e414420b7deae07bc95d7cad6b9d774239c7599357c51005166
e16b377c45994e16fd13d892d4af3da9	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{},"body":{"departName":"财务部","parentId":null,"orgCode":"FIN","orgCategory":"2","departOrder":9,"status":"1","description":"会计出纳"}}	\N	admin	2026-11-25 17:37:09.317	\N	\N	3ee876ae7690a9f929dabf4261b945b54e8d2a62749f2041354e3cc0b064ea5f
569ab6d3f11fe05ec31a8271c278f624	0	0	\N	部门管理 - PUT /api/v1/depts/816d6207c9bf763e331b7a73bf192f12	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{},"body":{"departName":"财务部","parentId":null,"orgCode":"FIN","orgCategory":"2","departOrder":0,"status":"1","description":"会计出纳"}}	\N	admin	2026-11-25 17:37:15.526	\N	\N	cb5dca361b09fa6e5413a40afc4194efbab383fe95508eba6c80279f71c1dbfc
f3f420c730a167f6d771bda3b804a305	0	0	\N	部门管理 - PUT /api/v1/depts/816d6207c9bf763e331b7a73bf192f12	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	12	\N	\N	\N	{"query":{},"body":{"departName":"财务部","parentId":null,"orgCode":"FIN","orgCategory":"2","departOrder":9,"status":"1","description":"会计出纳"}}	\N	admin	2026-11-25 17:37:22.773	\N	\N	4b91551a9ca0ad5d1b3cab2d0b13b233346e7f1b16096df74a76984d25a9c358
60d2fdb5849a592fbb2252c707a1b438	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	61	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:37:36.157	\N	\N	5543e157083e728c05d682ec14a90abc282bf551ea1e9484eab81398829278a6
876258acb18b4f47e63d77b8e14f3a05	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	12	\N	\N	\N	{"query":{},"body":{"departName":"前端组","parentId":"274ae154d607d1cb6eaf902205102219","orgCode":"TECH_FE","orgCategory":"2","departOrder":0,"status":"1","description":"前端组"}}	\N	admin	2026-11-25 17:38:00.16	\N	\N	cd0b2881b4776889ad23224d164c233d9a44b5b9786bc400fe18fc046cf91c87
19553f8f15a5a4fe3fd94bcf31d56208	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{},"body":{"departName":"后端组","parentId":"274ae154d607d1cb6eaf902205102219","orgCode":"TECH_BE","orgCategory":"2","departOrder":1,"status":"1","description":"后端组"}}	\N	admin	2026-11-25 17:38:25.744	\N	\N	569b2aee3e7c26e24714d0d2c30c245fc855d5fe4e9084b282b55fbfdfe7144c
003486fc3194f17db4e52db3ae005ac9	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	15	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:38:36.117	\N	\N	5b4f02284e6e799dd46831da16e0fddd3f61b3d237bbf5fd6ffabedc81c1e722
8828cd776d5fe06f65f509e3a35fa4fb	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{},"body":{"departName":"测试组","parentId":"274ae154d607d1cb6eaf902205102219","orgCode":"TECH_QA","orgCategory":"2","departOrder":1,"status":"1","description":"测试组"}}	\N	admin	2026-11-25 17:38:45.636	\N	\N	887972a0d19dc5c073d43f5ffdd5183830d48c2caa4fe4f28a745c81f8905ba3
fa7694aeb8b18ef87f573d5379eea19d	0	0	\N	部门管理 - PUT /api/v1/depts/9ad8689d847c849d14459b9749d561c1	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{},"body":{"departName":"测试组","parentId":"274ae154d607d1cb6eaf902205102219","orgCode":"TECH_QA","orgCategory":"2","departOrder":2,"status":"1","description":"测试组"}}	\N	admin	2026-11-25 17:38:55.976	\N	\N	5d8a7ee831f950dc1b3c62cf56af668041d98f7380fd3a14aa911e27304f69de
ab3431e3503f6e7589a7b71e9bfacda3	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	68	\N	\N	\N	{"query":{},"body":{"departName":"运维组","parentId":"274ae154d607d1cb6eaf902205102219","orgCode":"TECH_OPS","orgCategory":"2","departOrder":3,"status":"1","description":"运维组"}}	\N	admin	2026-11-25 17:39:25.097	\N	\N	a48f62ee2309a73e234ff6e740128df25aec1c432e88511e012bc72d4fd7bc45
6173436d37d95335b303b6ad311d1b83	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	5	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:39:36.207	\N	\N	190b582117d734936a18143d5ddfcbf41910e3630f28c77ecba4562e144ede97
ae21bab15d7324f4f1c66e4c4f39e8c4	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	12	\N	\N	\N	{"query":{},"body":{"departName":"产品组","parentId":"77b8a4d94ceb842f64b2d9d80e748b14","orgCode":"PROD_PM","orgCategory":"2","departOrder":0,"status":"1","description":"产品组"}}	\N	admin	2026-11-25 17:39:55.894	\N	\N	4f49e71245d0ce4655b5fb5f75a3183af93086ba2522416ea91ed62aa426d4ee
27c71fcbc00782943ad3d71dcb611311	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{},"body":{"departName":"设计组","parentId":"77b8a4d94ceb842f64b2d9d80e748b14","orgCode":"PROD_UI","orgCategory":"2","departOrder":1,"status":"1","description":"设计组"}}	\N	admin	2026-11-25 17:40:26.118	\N	\N	84b535267ba3fa24f91c6ce458689f97e69f7da142e97eb5dc84f0692c2c3e93
ef0ab0457efe4f8628100e10cf3be94c	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	55	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:40:36.159	\N	\N	4fac64baf46938eec1abd55cf0b1d3a4d6a2c6cb5e4b2c07f9ece76792c7332c
567d96cc222ba42196501388da6de20c	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	67	\N	\N	\N	{"query":{},"body":{"departName":"品牌组","parentId":"58cfac62e97a7e010be281db024ac135","orgCode":"MKT_BRAND","orgCategory":"2","departOrder":0,"status":"1","description":"品牌组"}}	\N	admin	2026-11-25 17:40:51.955	\N	\N	118e95c71b933a8dc41ed7b9b2f8a87f85dfc4027c0648a05665d8d191c44112
425ebfe9330bd65e84e7392a0f414f07	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	13	\N	\N	\N	{"query":{},"body":{"departName":"推广组","parentId":"58cfac62e97a7e010be281db024ac135","orgCode":"MKT_PROMO","orgCategory":"2","departOrder":1,"status":"1","description":"推广组"}}	\N	admin	2026-11-25 17:41:20.422	\N	\N	603e5a9eb88a98e8e1e03c32fa27d0b92ecf80076a9e3f89d866d6c16147c3fd
46554efab8e1867b7f14e05c67fdeeb4	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	60	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:41:36.168	\N	\N	72cd99d0be1d04f4d80dceababec40e670543fb396071ee38e6322f3937cc5f7
1378d1512307628815da3894fedcd300	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	6	\N	\N	\N	{"query":{},"body":{"departName":"内容组","parentId":"77b8a4d94ceb842f64b2d9d80e748b14","orgCode":"MKT_CONTENT","orgCategory":"2","departOrder":2,"status":"1","description":"内容组"}}	\N	admin	2026-11-25 17:41:42.777	\N	\N	3520c12c7fd67a3b2391d7c3b4bccd10386092bbe8d850f0b771c6a8a0b26541
7108ff7e9086449f8e886163f4e231da	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	12	\N	\N	\N	{"query":{},"body":{"departName":"销售一组","parentId":"1c6a947771e96e20b3074f8c4167a682","orgCode":"SALES_D1","orgCategory":"2","departOrder":0,"status":"1","description":"销售一组"}}	\N	admin	2026-11-25 17:42:14.548	\N	\N	667cdee4115fb505376eadee2d6974e36fcb11cd8554839babc7f91601bbcde3
4896cf8dce38f78cf7914f48552aa7dd	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	62	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:42:36.162	\N	\N	5a92f58db813baac663b2e46b882cd4ee565452b91afcd15f711ea001681ce6d
0e0f9e99f502d1aaab904b148521921c	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{},"body":{"departName":"销售二组","parentId":"1c6a947771e96e20b3074f8c4167a682","orgCode":"SALES_D2","orgCategory":"2","departOrder":1,"status":"1","description":"销售二组"}}	\N	admin	2026-11-25 17:42:37.729	\N	\N	46aca6c9a357e7bbfbcf7637ff4fe4e573a8466ce2d4c00cccb91db629adb103
392cb538d3e23f0ac35543c420b647dc	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	69	\N	\N	\N	{"query":{},"body":{"departName":"渠道组","parentId":"1c6a947771e96e20b3074f8c4167a682","orgCode":"SALES_CHANNEL","orgCategory":"2","departOrder":2,"status":"1","description":"渠道组"}}	\N	admin	2026-11-25 17:43:06.42	\N	\N	ffa2f65083588d1709120ce7910b04b74a578a009bfeecfad15f1374c733ce9b
ab5d112ff531d074b59eb1dbbdb68f8d	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:01:35.137	\N	\N	eecda4b9e35d40761dae3c63f62c7c345b6abd1046855393be29e7bc662db3f6
fd072a1bf0db05db4322b83807681a13	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	69	\N	\N	\N	{"query":{},"body":{"departName":"大客户组","parentId":"1c6a947771e96e20b3074f8c4167a682","orgCode":"SALES_KA","orgCategory":"2","departOrder":3,"status":"1","description":"大客户组"}}	\N	admin	2026-11-25 17:43:35.917	\N	\N	1c869fb42b3fc70755a693a82d8c1a1f9445e6dc8cd9d5d8a9859a16183a05e0
3e352c0d37224535f4885ad4f8eb9a32	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	63	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:43:36.171	\N	\N	d89fc1ddb22cd0de398e255e0b950df1834d72225757ed78ae467f6ca9271cd7
011db1d6f39cd0b4c664b4061930024e	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	11	\N	\N	\N	{"query":{},"body":{"departName":"用户运营","parentId":"d881adffce720e1da042c565454415ae","orgCode":"OPS_USER","orgCategory":"2","departOrder":0,"status":"1","description":"用户运营"}}	\N	admin	2026-11-25 17:44:03.5	\N	\N	2017b6c3cec80fe44a2756dd3d76eab5a44f05c455ecfe245de84deb5065d0c5
6a3e8761ce189f6bfa21355ccdd12a4b	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	76	\N	\N	\N	{"query":{},"body":{"departName":"内容运营","parentId":"d881adffce720e1da042c565454415ae","orgCode":"OPS_CONTENT","orgCategory":"2","departOrder":1,"status":"1","description":"内容运营"}}	\N	admin	2026-11-25 17:44:22.587	\N	\N	cebc4000fbb4066fa178d0d03f9853d7f634922ac2215f206cf0f86c4185ba9f
60929a318c706ec7a2796bf35c3bb010	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:44:36.247	\N	\N	35f46d45f1c31df2c9417182af949183c47155d4f4f4477636b81412af5fa597
935f47aba2c54cb2bc01b864703f4246	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{},"body":{"departName":"数据运营","parentId":"d881adffce720e1da042c565454415ae","orgCode":"OPS_DATA","orgCategory":"2","departOrder":2,"status":"1","description":"数据运营"}}	\N	admin	2026-11-25 17:44:42.111	\N	\N	f8b75e192ea7459736a0eaa060678078ff13cd92934b90e3b73ce9e98c879e62
a33ce1e08d5be09426cd592ba1d28a4a	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{},"body":{"departName":"售前支持","parentId":"d72db45b3ad8dfb69683dc85cf46dd42","orgCode":"CS_PRE","orgCategory":"2","departOrder":3,"status":"1","description":"售前支持"}}	\N	admin	2026-11-25 17:45:15.399	\N	\N	c330a332b73b9bf9ca1357cdaeee84e0a5aa06f8a1d0f021c288466603a2940a
7aa58611cc3f5672942cb8fc63d6cab2	0	0	\N	部门管理 - PUT /api/v1/depts/c61d7eeb14bfc68321c7af4db06b6f62	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{},"body":{"departName":"售前支持","parentId":"d72db45b3ad8dfb69683dc85cf46dd42","orgCode":"CS_PRE","orgCategory":"2","departOrder":0,"status":"1","description":"售前支持"}}	\N	admin	2026-11-25 17:45:31.056	\N	\N	caab9aa14e4082833399b54e774cd5c50d766ba5d26f19119e0de666266c4c78
3a2ec2e4968dc6a77955dc2db71289b4	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	5	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:45:36.114	\N	\N	a385a7b7b20ea8964f9159580deffceec907076a440f8e9ec57f874953f6e5fe
468e2a065a7044ee944a96b907cf0c69	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	73	\N	\N	\N	{"query":{},"body":{"departName":"售后支持","parentId":"d72db45b3ad8dfb69683dc85cf46dd42","orgCode":"CS_POST","orgCategory":"2","departOrder":1,"status":"1","description":"售后支持"}}	\N	admin	2026-11-25 17:45:56.956	\N	\N	29a46a6f53dbaaa2cc350ce01c95e5d0a1819672b5a67ac98d429259b5126758
709115ab518267cf171e99f8653bbef5	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{},"body":{"departName":"招聘组","parentId":"de37e8ca90ea00ecb18505583129bdc6","orgCode":"HR_RECRUIT","orgCategory":"2","departOrder":0,"status":"1","description":"招聘组"}}	\N	admin	2026-11-25 17:46:15.607	\N	\N	1686495edd1d83a76198480e1a8a306807f38724489cbb0b13b703eaf3f0c666
fa97603067260f27f9188a3e12d245c0	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:46:36.102	\N	\N	3a646afebc135f76e205562616ae6978f5878fb67fdadb809298733101f81a3f
ec8f59ecdbf67571cd39449f7bc7db2c	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{},"body":{"departName":"薪酬绩效组","parentId":"de37e8ca90ea00ecb18505583129bdc6","orgCode":"HR_COMP","orgCategory":"2","departOrder":1,"status":"1","description":"薪酬绩效组"}}	\N	admin	2026-11-25 17:46:40.769	\N	\N	bf94f7372ca3006fd4b5debf70f5fc542d4c53ea2b8d3ed1204e7c461b75061e
e82e5270b39187fbfdc56e551cab9981	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	13	\N	\N	\N	{"query":{},"body":{"departName":"会计组","parentId":"816d6207c9bf763e331b7a73bf192f12","orgCode":"FIN_ACC","orgCategory":"2","departOrder":0,"status":"1","description":"会计组"}}	\N	admin	2026-11-25 17:47:24.645	\N	\N	6a3d9ec61e9e93fa9b7f0360c9045e824cf1d9aeccde905a1a838d9b2478070f
9a83a5426d5bc6d4ad14308a14a8d1d6	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	5	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:47:36.19	\N	\N	3e763790f3cb188749804dc4d4f820411189ec470d1be00d55acdfa1bf90bd13
78e42ddaea045bf369c0d92f64467725	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	66	\N	\N	\N	{"query":{},"body":{"departName":"出纳组","parentId":"816d6207c9bf763e331b7a73bf192f12","orgCode":"FIN_CASH","orgCategory":"2","departOrder":1,"status":"1","description":"出纳组"}}	\N	admin	2026-11-25 17:47:50.271	\N	\N	67e1bef6b1cc7d9c83d158f7ed3bae562546243bdd582cd5f6567db745832b07
14cdbebab41c4b467e2d7baf33a5783f	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:48:36.299	\N	\N	dab7dfe4036732408256834003f90632cb0bf8ac2d64f3731e1ee4729acf9334
9fa8cb43718a575e874d7b1054016b35	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:50:34.288	\N	\N	77f07f5ea68b9e7f20725cdf01060a4991adbb9a1738b1f6203c1a4785a75c52
8e56a8cffc8cd5c9c9073abb3cb9cf12	0	0	\N	部门管理 - POST /api/v1/depts/batch-delete	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	150	\N	\N	\N	{"query":{},"body":{"ids":["2c0bf467e461e73e981347c7d74b1e93","35ee4e71ee587a3d35e65685c7099945","745eef237b136b80f8282b35f65ed319","841fc60ce80e71f8dc510eb00b09ffc8","a59c8e98d0668f27050cc6643f0d1323","bca36f8c3179d3a173b83fd617cb29a7","c61d7eeb14bfc68321c7af4db06b6f62","c8a10e918f99f82b2f9519852bfefad6","f73ff9e430679db4369c663cbf6514d2","0847457716c7716aac2c1b9d47b73b47","274ae154d607d1cb6eaf902205102219","35f85c4c269dcd1518e0412452de9d4f","3ef268de18e3969dd5333f3f0ad25f8b","443e40b5ad9612ff25e08710b1022f7d","6310f397f3d76435078e5c5c5bf827ac","c0d2f9f658dceb6db5268eb71ffad071","c3b5e30263ddea3c5bc84e2b861c24ea","e06051585e43bcb45037010860d3120a","6adf955acd591b7d43e029de3d615d74","77b8a4d94ceb842f64b2d9d80e748b14","9ad8689d847c849d14459b9749d561c1","a13a5e592da7d6ffb2dd34e0c06229d2","b81b0407052c33a23cec39508db541e6","1023b903c98fa3d34308841ecd7476c2","58cfac62e97a7e010be281db024ac135","7c64c3e5efb5353a660b227f13e95e2e","1c6a947771e96e20b3074f8c4167a682","d881adffce720e1da042c565454415ae","d72db45b3ad8dfb69683dc85cf46dd42","de37e8ca90ea00ecb18505583129bdc6","69ecd174e774284c203a131eefaa52bb","816d6207c9bf763e331b7a73bf192f12"]}}	\N	admin	2026-11-25 17:50:47.323	\N	\N	434ef33c17e16c83bfc123230f4c387697645e3afbc9703f9494ebc767ea9621
79d3f853f5651a924330937bcdf9f877	0	0	\N	部门管理 - POST /api/v1/depts/batch-delete	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	12	\N	\N	\N	{"query":{},"body":{"ids":["274ae154d607d1cb6eaf902205102219","77b8a4d94ceb842f64b2d9d80e748b14","1c6a947771e96e20b3074f8c4167a682"]}}	\N	admin	2026-11-25 17:50:55.706	\N	\N	01aee87c459430dfcb7a9dafd1a8543b329406ced9389d6e39ad1697e5260857
4ee22379e563979541aa6376f29f5fe3	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:51:36.285	\N	\N	142e46b0b6314f5bdf31d3b64860c02b3cf3985a6422de354b12eef378e1a2ca
63a60bb96a95d1ddd3911506b6cf7a50	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:43:24.313	\N	\N	b7bbb7f0f5f00fcf28c387d5101938a4f27958ad2c5b71a3dc126afdc8c33d71
9b66be0a37c2e37c545ce7c0904d37c5	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{},"body":{"departName":"总经办","parentId":null,"orgCode":"GM_OFFICE","orgCategory":"2","departOrder":0,"status":"1","description":"决策辅助、文件流转、高层日程"}}	\N	admin	2026-11-25 17:52:22.78	\N	\N	daf674ef4b45dc1e4fd920abe33a55809c93ea06a5bd1147164603d8c935500f
a01e58a8ad0e512444eb7f122fa7b1a4	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	61	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:52:36.235	\N	\N	7e7a34f3f47d574a2d2a7eff0ef05db948b72d293f64a27fab9613cced82dbd8
8dbe3d4bcd3b4d4672f01e07e376079d	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	14	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:53:10.766	\N	\N	82d948536de0f9db9a7ce44cbab378c43a058cb45feb5bf148c8934f6f8540c6
50cd14cf5eca71c58d35f4fe7d38916d	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	2	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:53:10.799	\N	\N	f79f10c16b4cd86242cf1574bb9cb360bbb11bb19cbc9e75186e4da067527b1d
725bdefb2052d43fd250e9493e62a341	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	11	\N	\N	\N	{"query":{},"body":{"departName":"人力资源部","parentId":null,"orgCode":"HR","orgCategory":"2","departOrder":1,"status":"1","description":"招聘、薪酬、绩效、培训"}}	\N	admin	2026-11-25 17:54:06.77	\N	\N	a1f6bed816c6b24bb41658fef1ba893f6cdeb40fc2f294b73fa83a66e59e5652
161fc526f268a7bff288c48cef38ac54	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	61	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:54:11.243	\N	\N	88576659880c848275cac5c9394c7ae26fabb09ecc97ae9b55f0d9e330976231
944b64ff6cbace436208e503e19ffcac	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	5	\N	\N	\N	{"query":{},"body":{"departName":"行政部","parentId":null,"orgCode":"ADM","orgCategory":"2","departOrder":2,"status":"1","description":"前台、办公环境、资产、车辆、接待"}}	\N	admin	2026-11-25 17:54:26.977	\N	\N	22759c24044d0b6ce96080ead179d16784abcf6106fe929c380b46c377c4a5cd
b2650851d88c3dd3e9684898598e1bb1	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	69	\N	\N	\N	{"query":{},"body":{"departName":"财务部","parentId":null,"orgCode":"FIN","orgCategory":"2","departOrder":3,"status":"1","description":"会计核算、资金、报表、税务"}}	\N	admin	2026-11-25 17:54:55.902	\N	\N	69e41d2cf39b1607b027b91f2963be94ba55b84738f3b44ccea61bbe3c6092ea
2714475ee1ab146c745b804162ae5a18	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{},"body":{"departName":"法务部","parentId":null,"orgCode":"LEGAL","orgCategory":"2","departOrder":4,"status":"1","description":"合同审核、合规、纠纷"}}	\N	admin	2026-11-25 17:55:10.156	\N	\N	682e4ba540572b202cf1b64e34a0530f5fe2b2de60139cb2f04b4bb6b39de7bd
bc4685e324349bd11890cdbc41d8ad43	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	59	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:55:10.656	\N	\N	37c1ac59d3fa2826c7db3f8a4ecd9b16ee46804a36cea0a0b2854e3a9a371d2e
167cd11b927c7f55a74e2fe4880c87a4	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	11	\N	\N	\N	{"query":{},"body":{"departName":"产品部","parentId":null,"orgCode":"PROD","orgCategory":"2","departOrder":5,"status":"1","description":"需求、原型、用户体验"}}	\N	admin	2026-11-25 17:55:32.513	\N	\N	4cd87e0c5470eb01293eb39dee8456a8abc260957c8a9cae25a24ea2bfc46a04
f88a907d0941751837a9166ae445e0ce	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	66	\N	\N	\N	{"query":{},"body":{"departName":"技术部","parentId":null,"orgCode":"TECH","orgCategory":"2","departOrder":6,"status":"1","description":"研发、测试、运维"}}	\N	admin	2026-11-25 17:56:01.165	\N	\N	10208374050964cc5cf7576bd99871838274d9577ab4ea7350948bbf51836d33
f8e6e19bd036f3ae9b2c5b57fa8059e9	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:56:10.599	\N	\N	86e4247a0dc248f8d823cf1f0e4cd0a480e9c9c278c332911f198e4397079016
3fdfc16e17c9c15b55b366446c6b1642	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	6	\N	\N	\N	{"query":{},"body":{"departName":"市场部","parentId":null,"orgCode":"MKT","orgCategory":"2","departOrder":7,"status":"1","description":"品牌、推广、获客"}}	\N	admin	2026-11-25 17:56:18.7	\N	\N	d1e310480347c65c9dcff1389da664909b00024bf8605e77b9b209a6ccb9db3a
5a87823609a47726d51fc5fe7e3c75a1	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	62	\N	\N	\N	{"query":{},"body":{"departName":"销售部","parentId":null,"orgCode":"SALES","orgCategory":"2","departOrder":8,"status":"1","description":"签单、客户关系、回款"}}	\N	admin	2026-11-25 17:56:34.418	\N	\N	8e3bc5eff3ce721358e28b108233167a61765141cde458612f961f2b5ec2c88a
30d94aa4bbd8fb8ba076c50b4b445623	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	64	\N	\N	\N	{"query":{},"body":{"departName":"运营部","parentId":null,"orgCode":"OPS","orgCategory":"2","departOrder":10,"status":"1","description":"用户、内容、数据运营"}}	\N	admin	2026-11-25 17:56:52.646	\N	\N	42c613db5c8a10201ac2e4ffe37e0e481908bfca8fb719779794b5b5163cc927
343aec92536664739e2cf542d4a3b6e2	0	0	\N	部门管理 - PUT /api/v1/depts/f026194db425743c7cd02d3ed50deb67	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{},"body":{"departName":"运营部","parentId":null,"orgCode":"OPS","orgCategory":"2","departOrder":9,"status":"1","description":"用户、内容、数据运营"}}	\N	admin	2026-11-25 17:56:59.092	\N	\N	3ba5ebe2e0544032164dc1f349249fd12e340d5a90b70e78062446936cd4141f
d0cbec01a0952c850270ea7dc571bd50	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	4	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:57:10.679	\N	\N	525977169c28165605b159f6a94ec604ba896212f333d1fc4f802a8f5d6091ff
e13ea2f49bd18d1c86cd534c65afe661	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	5	\N	\N	\N	{"query":{},"body":{"departName":"客服部","parentId":null,"orgCode":"CS","orgCategory":"2","departOrder":11,"status":"1","description":"售前咨询、售后支持"}}	\N	admin	2026-11-25 17:57:18.38	\N	\N	395315dc5a1f9007b3b4333ceeb74307f7f7dc6408a89405fc21ac1ae1803ba0
dc54a7d20741e8171ec1e219bc28832f	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	103	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:57:20.988	\N	\N	cbc4ee225af2691bc3049e6c2dd689564d52ba26f97e8a52900fc8de05732744
9ca85ea61ecba5395c96f24ba6964e4b	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	6	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:57:21.021	\N	\N	2c8e60a0669cb7663e72c46015bd002def9ecd4b75653dfef0bb7af1bc6a9bf2
4c8df6e9eb5efbea40ae1e82e65a607c	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	107	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:57:35.212	\N	\N	bf0c704249991f38b1c5ba5839fc5b434ed1982a2f6a453180daaf353ef63bfd
51e877eedcb534acc2677e085a346990	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	3	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:57:35.24	\N	\N	763301a62bf3e5690f58196e722f6987e032d22c851483005b5713db06870719
adf45d09448551e19565e96933752725	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:58:35.29	\N	\N	81654927b54106c6ec552807446c781295a3c36042c313264a1e2bd2b36830c1
06165d9b718b44dd892c2f005a510bdf	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 17:59:35.122	\N	\N	7402dee8582eff8b20c6a7a8745f8587ce96c6d8010c6349461a48e1ae8508ed
fb39d173de543a1ece7e448684402e90	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{},"body":{"departName":"战略组","parentId":"af598343d6bd897baa306c5489790bc7","orgCode":"GM_STRATEGY","orgCategory":"2","departOrder":0,"status":"1","description":"规划、经营分析"}}	\N	admin	2026-11-25 17:59:47.344	\N	\N	28aede42443bdaac42db21c5b3a156d9ef6f6c4127070bc8eb54e23e00d3e4cb
094097fbfa4e6cbb0d8d739c793b8828	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{},"body":{"departName":"督办组","parentId":"af598343d6bd897baa306c5489790bc7","orgCode":"GM_SUPERVISION","orgCategory":"2","departOrder":1,"status":"1","description":"决议跟踪、跨部门协调"}}	\N	admin	2026-11-25 18:00:07.923	\N	\N	868ec94662c7415c3091656a460048d44e79db4a90a7587b68ebc7c18b2683a4
1a112d22ab9a2e228704e73d67df9081	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	62	\N	\N	\N	{"query":{},"body":{"departName":"秘书组","parentId":"af598343d6bd897baa306c5489790bc7","orgCode":"GM_SECRETARY","orgCategory":"2","departOrder":2,"status":"1","description":"高层日程、文书"}}	\N	admin	2026-11-25 18:00:29.063	\N	\N	9943e9a2ecfb1c6cdd5c4740d977485c7680409f7f2af2dd83e5ccfc2b83c5c0
c767634b85716b03639b60972cdb9636	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	56	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:00:35.236	\N	\N	355c4fe6e2a9b930eb52b15bf4fc1a4601d74257efcc3f6a0f54d5ec663734d0
d940b9319ff742d974b9067749bc278c	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	12	\N	\N	\N	{"query":{},"body":{"departName":"招聘组","parentId":"064719832c25df4ba5f58bfbf8872284","orgCode":"HR_RECRUIT","orgCategory":"2","departOrder":0,"status":"1","description":"招聘、面试、入职"}}	\N	admin	2026-11-25 18:01:03.204	\N	\N	a1993a877f5959306b3be0a35aa84e1ba46952b67c9ab59dc0631ef72b2a39e3
ccfe0c10790a683225c56bc8a69524cb	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{},"body":{"departName":"薪酬绩效组","parentId":"064719832c25df4ba5f58bfbf8872284","orgCode":"HR_COMP","orgCategory":"2","departOrder":1,"status":"1","description":"薪资、社保、绩效考核"}}	\N	admin	2026-11-25 18:01:25.473	\N	\N	ae8acee341261650ff4531d1506bc20be0fbade28060ee17df362a45ba7079e7
287d719ddf66fe5938dc4168a4f8bd5d	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	64	\N	\N	\N	{"query":{},"body":{"departName":"培训组","parentId":"064719832c25df4ba5f58bfbf8872284","orgCode":"HR_TRAIN","orgCategory":"2","departOrder":3,"status":"1","description":"培训、人才培养"}}	\N	admin	2026-11-25 18:01:46.114	\N	\N	a9b737bf4301be92fcfd28d6e547455392371020472047a82d2abc632a1bee97
ca8ecd475b60f109c69b3cec1bf1d6f1	0	0	\N	部门管理 - PUT /api/v1/depts/2854ec06659a0c455a77e6f310cc96c0	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{},"body":{"departName":"培训组","parentId":"064719832c25df4ba5f58bfbf8872284","orgCode":"HR_TRAIN","orgCategory":"2","departOrder":2,"status":"1","description":"培训、人才培养"}}	\N	admin	2026-11-25 18:01:53.138	\N	\N	cc1c0765b49b65bfa7e5550fca84c03c4ed3601aa21e4383da0a85330e0ea8c5
2a694e2ff30041d28ae578058a03891a	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	14	\N	\N	\N	{"query":{},"body":{"departName":"员工关系组","parentId":"064719832c25df4ba5f58bfbf8872284","orgCode":"HR_ER","orgCategory":"2","departOrder":3,"status":"1","description":"合同、考勤、离职"}}	\N	admin	2026-11-25 18:02:20.325	\N	\N	44634d9a009039dbde8eae34c1f47e9560365d018da75dbbcbb8eab6bffd8eaa
01cb4bb09c7f4c76f952b92c8c0f1e39	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	5	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:02:35.234	\N	\N	376ce5bc8d1b63a8e9dd0325661ddbb023374d91d5a761a64bd2c0b13948cc4f
5992bedcd380f8953815516da60137df	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	67	\N	\N	\N	{"query":{},"body":{"departName":"前台接待组","parentId":"2128fcf7ff6c60920e2294e2b009b5ab","orgCode":"ADM_FRONT","orgCategory":"2","departOrder":0,"status":"1","description":"来访、收发、办公环境"}}	\N	admin	2026-11-25 18:02:50.275	\N	\N	1ae45a79389e0dce6bccc0d24ed013d8b989ed5f583e1f044d9dcf63e43eba48
daa43c80e78f497fc4bc4795e445324c	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{},"body":{"departName":"资产管理组","parentId":"2128fcf7ff6c60920e2294e2b009b5ab","orgCode":"ADM_ASSET","orgCategory":"2","departOrder":1,"status":"1","description":"办公用品、固定资产"}}	\N	admin	2026-11-25 18:03:14.014	\N	\N	4dedd816cd5e6e72a8a2463c949fc6c9728476a7acd81a3c3dbe7e71e21db7e0
dba7a24e6a8adbeba69c8915d68d891c	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	66	\N	\N	\N	{"query":{},"body":{"departName":"测试组","parentId":"d3e1489934c2d5d5cf10e4cd614c4404","orgCode":"TECH_QA","orgCategory":"2","departOrder":2,"status":"1","description":"功能/自动化测试"}}	\N	admin	2026-11-25 18:07:56.827	\N	\N	0f9c8fefb5672feb8dd7d8f90a0bcc8af519cfa9d8e7f20458cccd8e828a284e
9f66c0e69cd68ab67a756691e92f0624	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{},"body":{"departName":"后勤保障组","parentId":"2128fcf7ff6c60920e2294e2b009b5ab","orgCode":"ADM_LOGISTICS","orgCategory":"2","departOrder":2,"status":"1","description":"车辆、食堂、安保、保洁"}}	\N	admin	2026-11-25 18:03:33.024	\N	\N	435e3073b962a4a11f30588c065afa504cc2793b9465cb6a3ffc5dabc1359814
c309d5a1177f479368bfc97071584072	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	63	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:03:35.233	\N	\N	0c1e13f578dd86a4f31ad2249eefc9564b4179ef195da2c46379388b389dc94d
e65fefb80451fed8a9b7511629304343	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{},"body":{"departName":"会计组","parentId":"555f8f0307a3d92dfa3923b58889decb","orgCode":"FIN_ACC","orgCategory":"2","departOrder":0,"status":"1","description":"记账、报表、税务申报"}}	\N	admin	2026-11-25 18:03:56.808	\N	\N	07ffd74ad43ad6e40be1cd4ed392f76f1349e7a4554ccccb1ffa1aabd9b03fba
4cf6cdc58175c0e95b814ce72bbe343a	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	61	\N	\N	\N	{"query":{},"body":{"departName":"出纳组","parentId":"555f8f0307a3d92dfa3923b58889decb","orgCode":"FIN_CASH","orgCategory":"2","departOrder":1,"status":"1","description":"收付款、银行、现金"}}	\N	admin	2026-11-25 18:04:18.421	\N	\N	97c8dfa701d95d99553c22843b9d226da7f901210295cc517ab6dd7abbe82a95
a2b13fda2b130e705280bd304f0cd2c9	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:04:35.241	\N	\N	d32814ed3db2e523c8701f69069b3849d26db75d13eb09b877a418e8bf665231
32f49c658344b61042404842f382b6e2	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{},"body":{"departName":"成本组","parentId":"555f8f0307a3d92dfa3923b58889decb","orgCode":"FIN_COST","orgCategory":"2","departOrder":2,"status":"1","description":"成本核算、预算控制"}}	\N	admin	2026-11-25 18:04:46.6	\N	\N	a7b0f9bc088fb3dabb70dd9e03682b97251b6fa6d318153baa951eedb7a95b17
00f1ef4922776fbcccdcb5b47713a459	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{},"body":{"departName":"合同组","parentId":"531503f12d9cdf729d9ce8ae535ca6ab","orgCode":"LEGAL_CONTRACT","orgCategory":"2","departOrder":0,"status":"1","description":"合同起草审核、归档"}}	\N	admin	2026-11-25 18:05:06.719	\N	\N	a53e94725e8d6201273acf7e7afe9a573b56718a2a8c50c0f31e80839acd1a24
3bf5f756c17274cfa969749c923d51d0	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	70	\N	\N	\N	{"query":{},"body":{"departName":"合规组","parentId":"531503f12d9cdf729d9ce8ae535ca6ab","orgCode":"LEGAL_COMPLIANCE","orgCategory":"2","departOrder":1,"status":"1","description":"法律风险、监管合规"}}	\N	admin	2026-11-25 18:05:24.362	\N	\N	7b981d8ddd7be920b64dc825285a413b25bd3929e9999eabb92645929da4d497
69cf03a8852fb21dd6abef291cc0d703	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	6	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:05:35.127	\N	\N	5aa84295fe72d548c7658dc6bfe0f52e82e9c9508e24f06c558ba7748a8302ce
19fb300bd649e861120212546b52184f	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{},"body":{"departName":"知识产权组","parentId":"531503f12d9cdf729d9ce8ae535ca6ab","orgCode":"LEGAL_IP","orgCategory":"2","departOrder":2,"status":"1","description":"专利、商标、著作权"}}	\N	admin	2026-11-25 18:05:51.989	\N	\N	4ad38a580958de9cd836085769b7be8ab17f317359a5c30a8f554bdf2d09138c
e23ec0141f48d1f3d4ab681c7d7f478f	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	4	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:27:24.264	\N	\N	d2ef9678ca72b485900c9dcf774ccd53cd375df7d1a8ac2d9920ed9ef20e65c3
ddbf87495b8ebc968fc754442d000ed3	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	65	\N	\N	\N	{"query":{},"body":{"departName":"产品组","parentId":"1577baeb20661e0ba522c60351c101b2","orgCode":"PROD_PM","orgCategory":"2","departOrder":0,"status":"1","description":"需求、原型、PRD"}}	\N	admin	2026-11-25 18:06:14.641	\N	\N	625edc7565c4bdf41470dde4b99ca9493b7d6881088169632eae8a1b5ebf45bb
bc67f88e80392026d334f20c7645fb65	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{},"body":{"departName":"设计组","parentId":"1577baeb20661e0ba522c60351c101b2","orgCode":"PROD_UI","orgCategory":"2","departOrder":1,"status":"1","description":"UI/UX、视觉"}}	\N	admin	2026-11-25 18:06:34.406	\N	\N	faf89e535a86ae1d109af881230362f4d775a30282c842d594216bc1ff6f326d
d81a83f721be7ed09d7db7c6d0787b6f	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	4	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:06:35.182	\N	\N	251653b6f5248ae1fc0be99cf837dc6c0c5e4d708b51334ba0e2888212a24dbc
4e1964a2a4ecbbd52f02283c86701aed	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{},"body":{"departName":"用研组","parentId":"1577baeb20661e0ba522c60351c101b2","orgCode":"PROD_UR","orgCategory":"2","departOrder":2,"status":"1","description":"用户调研、可用性测试"}}	\N	admin	2026-11-25 18:06:57.739	\N	\N	1c68aea71a533fb1a88cc757e13d01274b5684f871e2fd6badaa6a356ddb1fe4
1d6258a736c1f06003bc6687ae171c23	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	64	\N	\N	\N	{"query":{},"body":{"departName":"前端组","parentId":"d3e1489934c2d5d5cf10e4cd614c4404","orgCode":"TECH_FE","orgCategory":"2","departOrder":0,"status":"1","description":"Web/小程序前端"}}	\N	admin	2026-11-25 18:07:21.274	\N	\N	3c710a345f70b6320b541de3b41f088b2c6fc32c0bef6f352309bb0cc45a3ba9
bfd5ac7d011b46ef12c44e8e705a20ec	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	6	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:07:35.135	\N	\N	304faba020242cabf2e1e21c64aca6eea0252f7424d47dd4fdd4e5a7426098c9
38a63f74cc60b6be752a2d5d43b6cb78	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	14	\N	\N	\N	{"query":{},"body":{"departName":"后端组","parentId":"d3e1489934c2d5d5cf10e4cd614c4404","orgCode":"TECH_BE","orgCategory":"2","departOrder":1,"status":"1","description":"接口、数据、服务"}}	\N	admin	2026-11-25 18:07:37.127	\N	\N	900290f15bf3dee89ce6ea4b5fd32027384798ebc7a1da59978825142ff7bac4
c5abbfa8efd916b22956bd98c1edb75a	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{},"body":{"departName":"运维组","parentId":"d3e1489934c2d5d5cf10e4cd614c4404","orgCode":"TECH_OPS","orgCategory":"2","departOrder":3,"status":"1","description":"部署、监控、故障"}}	\N	admin	2026-11-25 18:08:17.024	\N	\N	140923d8eb97f389a88b3aef5080f3464e2e8543dc03ccab8339f5450329e859
ce44dc0ebbf057d51524875892ae3fbb	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	63	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:08:35.198	\N	\N	cb6e40380ee892f35559b598b17b79c47e0529abba5943dc193e0bd6bb6c337e
cb35e352fba51b05592d0c9f1ac0e57a	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{},"body":{"departName":"数据组","parentId":"d3e1489934c2d5d5cf10e4cd614c4404","orgCode":"TECH_DATA","orgCategory":"2","departOrder":4,"status":"1","description":"数据仓库、BI"}}	\N	admin	2026-11-25 18:08:38.875	\N	\N	541da66250587bbc6d86e303aaeb32166428b857138f68a4b92ec8ef4abddf61
30d0d1988788adddcb9c204ec1a15b01	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{},"body":{"departName":"品牌组","parentId":"5db52b767a1cbd831537d81976df3a95","orgCode":"MKT_BRAND","orgCategory":"2","departOrder":0,"status":"1","description":"品牌定位、VI、公关"}}	\N	admin	2026-11-25 18:08:57.652	\N	\N	61973c79a1e8d3d56fd3178fdcf45454fbc6b15dc1c1c09a4633caa88e0b161c
621bbdac6cd2c34fd5dede228051899d	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	11	\N	\N	\N	{"query":{},"body":{"departName":"推广组","parentId":"5db52b767a1cbd831537d81976df3a95","orgCode":"MKT_PROMO","orgCategory":"2","departOrder":1,"status":"1","description":"投放、渠道获客"}}	\N	admin	2026-11-25 18:09:26.323	\N	\N	15320004eaa973b5228086c54b23ab8eb4b70d15138cd76923d9f8aed4e1f5fb
2be7424c32c864690172db500ba118a3	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:09:35.148	\N	\N	e3d2041d0b5eb19c552a1455b76de6028fdf464605474e3fea1d69bee55a6232
490e5e5ef991e0ad884aebc8f725ad24	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	66	\N	\N	\N	{"query":{},"body":{"departName":"内容组","parentId":"5db52b767a1cbd831537d81976df3a95","orgCode":"MKT_CONTENT","orgCategory":"2","departOrder":2,"status":"1","description":"文案、新媒体、素材"}}	\N	admin	2026-11-25 18:09:49.059	\N	\N	92cec44df61db24049543000a7813c4ff4cf03277692738239ca381a0cfaa276
aec621e926143a5ddc35a6958012bef9	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	78	\N	\N	\N	{"query":{},"body":{"departName":"活动组","parentId":"5db52b767a1cbd831537d81976df3a95","orgCode":"MKT_EVENT","orgCategory":"2","departOrder":3,"status":"1","description":"展会、线上活动"}}	\N	admin	2026-11-25 18:10:12.445	\N	\N	bd701143b8a459778e675c6deca601f43bfb7cf4c294fa94229b5a1a97d818f8
aa5244b0baa670daa1cf0008dc25a8e4	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	4	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:10:35.239	\N	\N	fd690fc7091c2d33507d43761d28483e33c9fff3215c871389090a1f954f7d7d
92a754d7a88eb45f62c6039e4e0f4b8d	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	6	\N	\N	\N	{"query":{},"body":{"departName":"销售一组","parentId":"6cae4d898c1073b39b0b0ddd5364c928","orgCode":"SALES_D1","orgCategory":"2","departOrder":0,"status":"1","description":"销售一组"}}	\N	admin	2026-11-25 18:10:36.637	\N	\N	50c315e94e15de4aea0bef4e09304304977e47f1b80602e3224c39a12d7f0500
30d5aae7840b6965d83aea46134c497d	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	66	\N	\N	\N	{"query":{},"body":{"departName":"销售二组","parentId":"6cae4d898c1073b39b0b0ddd5364c928","orgCode":"SALES_D2","orgCategory":"2","departOrder":1,"status":"1","description":"销售二组"}}	\N	admin	2026-11-25 18:10:54.126	\N	\N	e5931b4513abfde722219445db526896fb93b4dd1e611f1e13af574938f994f2
8aff3d2df934570698445d93d4292520	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{},"body":{"departName":"渠道组","parentId":"6cae4d898c1073b39b0b0ddd5364c928","orgCode":"SALES_CHANNEL","orgCategory":"2","departOrder":2,"status":"1","description":"代理商、合作伙伴"}}	\N	admin	2026-11-25 18:11:15.081	\N	\N	307a24d251c82cb11c7876f1011e6e77bd33327398eaecf7f5abdd3ccf80eccd
222f5b5785406a5827d0f4f02cc5d735	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	66	\N	\N	\N	{"query":{},"body":{"departName":"大客户组","parentId":"6cae4d898c1073b39b0b0ddd5364c928","orgCode":"SALES_KA","orgCategory":"2","departOrder":3,"status":"1","description":"重点客户维护"}}	\N	admin	2026-11-25 18:11:33.099	\N	\N	a0be9bac16b6d201ce1eaff78d4e1ccf070e57b61178c4c3817e6c17f6714e22
852d20053072613a98d4320919f7774f	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	56	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:11:35.222	\N	\N	6112784fcc50d26e55b1a221652a0b87ec12a0127afa5b0a4d769d0b4a349391
e4bdd0ff3f21d415a546c288b86c023f	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{},"body":{"departName":"用户运营","parentId":"f026194db425743c7cd02d3ed50deb67","orgCode":"OPS_USER","orgCategory":"2","departOrder":0,"status":"1","description":"拉新、留存、社群"}}	\N	admin	2026-11-25 18:11:53.319	\N	\N	148d76082ff57238c1d87dad8469124ae85259180f0abe7af5c108181ba41080
13c2454a51821343dfa287fc832f2bf1	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	72	\N	\N	\N	{"query":{},"body":{"departName":"内容运营","parentId":"4c5e87295e51cacc865bf92accb55875","orgCode":"OPS_CONTENT","orgCategory":"2","departOrder":1,"status":"1","description":"内容生产、审核"}}	\N	admin	2026-11-25 18:12:13.566	\N	\N	ef0a8d505a5a3f9ba70ad1e61daf6d1fa8c988a3c9b5ab536a79348566d277c9
2cf1fb4f9928b197919220674aba4b57	0	0	\N	部门管理 - PUT /api/v1/depts/af598343d6bd897baa306c5489790bc7	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	12	\N	\N	\N	{"query":{},"body":{"departName":"总经办","parentId":null,"departOrder":1,"description":"决策辅助、文件流转、高层日程"}}	\N	admin	2026-11-25 18:12:19.529	\N	\N	2502c932cb9845fd29fb839a784a0a9550f53eaca9b9ecbb10842830091c4803
2d50631649daedd5a47aee544e85269c	0	0	\N	部门管理 - PUT /api/v1/depts/b8453f144534871988e733ffbf2cebf4	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{},"body":{"departName":"薪酬绩效组","parentId":"064719832c25df4ba5f58bfbf8872284","departOrder":2,"description":"薪资、社保、绩效考核"}}	\N	admin	2026-11-25 18:12:19.557	\N	\N	ef405ba9a52b82c9a0e13ab68b7beb029b89fd99984ff2904676e157785cf655
7c12f773fbff8f327095dd1311f76d50	0	0	\N	部门管理 - PUT /api/v1/depts/2854ec06659a0c455a77e6f310cc96c0	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{},"body":{"departName":"培训组","parentId":"064719832c25df4ba5f58bfbf8872284","departOrder":3,"description":"培训、人才培养"}}	\N	admin	2026-11-25 18:12:19.584	\N	\N	46f317ea68c684d860a7894ecfb89795ba71c8d2e6e310ce250e8ffc7a3c869f
fe1e4780ce683f137261e5b959411b1c	0	0	\N	部门管理 - PUT /api/v1/depts/f366f71504c6b1ec8d21b93924f09b0d	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{},"body":{"departName":"员工关系组","parentId":"064719832c25df4ba5f58bfbf8872284","departOrder":4,"description":"合同、考勤、离职"}}	\N	admin	2026-11-25 18:12:19.611	\N	\N	1ca826443f3ceb9dba9d140591812af8b3a43f80eaf488a7e44fda8d6090d57a
23313267abf1aca152475436ce4af908	0	0	\N	部门管理 - PUT /api/v1/depts/064719832c25df4ba5f58bfbf8872284	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	121	\N	\N	\N	{"query":{},"body":{"departName":"人力资源部","parentId":null,"departOrder":2,"description":"招聘、薪酬、绩效、培训"}}	\N	admin	2026-11-25 18:12:19.64	\N	\N	ce8dcc6c31200d4defe488df50b7440bc4248f8f7a06c6cb16f621a21650009b
3b3c919faaabf605463bc52c81525ebd	0	0	\N	部门管理 - PUT /api/v1/depts/30b6686380c4ad34cfadaaf525b35905	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{},"body":{"departName":"前台接待组","parentId":"2128fcf7ff6c60920e2294e2b009b5ab","departOrder":1,"description":"来访、收发、办公环境"}}	\N	admin	2026-11-25 18:12:19.676	\N	\N	644b91dddb28f574a25e35d58078e86c2a365f8256c1d6bca8898023061f5f76
13446e66dbc0c00be30b5698c2dbf2e3	0	0	\N	部门管理 - PUT /api/v1/depts/32c636f441f362d0ecbd3cfc7173ba70	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{},"body":{"departName":"资产管理组","parentId":"2128fcf7ff6c60920e2294e2b009b5ab","departOrder":2,"description":"办公用品、固定资产"}}	\N	admin	2026-11-25 18:12:19.705	\N	\N	5d18faf73be0d1194649e7225113b1bcd61d0aee9f4ebc0d547c280e2e2dd915
04b11db9b73c6e6aebc97b3d4667b9a5	0	0	\N	部门管理 - PUT /api/v1/depts/128414f99c799b60253d912c371a7616	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	12	\N	\N	\N	{"query":{},"body":{"departName":"后勤保障组","parentId":"2128fcf7ff6c60920e2294e2b009b5ab","departOrder":3,"description":"车辆、食堂、安保、保洁"}}	\N	admin	2026-11-25 18:12:19.733	\N	\N	c791a7b02fdfbec3dcf307894170912914417d89e2e8955029cf30d61e3ab07d
961d082820ac6a5b48084eccad91cc38	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:26:24.301	\N	\N	cfaef71e1270fd28a807aa0914a51f777a41d90586370163b00c6a33a750168a
fa63361518673ca3bdcdc4eb17eca9e7	0	0	\N	部门管理 - PUT /api/v1/depts/fc237c66532784bbc636f47e7542955a	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	124	\N	\N	\N	{"query":{},"body":{"departName":"秘书组","parentId":"af598343d6bd897baa306c5489790bc7","departOrder":3,"description":"高层日程、文书"}}	\N	admin	2026-11-25 18:12:19.643	\N	\N	a26d69694cef0689d3ff09fc4f8adea86880ed223009cdab80c2d012878700b3
a9591457e6d869bd89771a4ba43c2dcf	0	0	\N	部门管理 - PUT /api/v1/depts/327938411ddc10ff9cf1f30bbee3b797	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	133	\N	\N	\N	{"query":{},"body":{"departName":"招聘组","parentId":"064719832c25df4ba5f58bfbf8872284","departOrder":1,"description":"招聘、面试、入职"}}	\N	admin	2026-11-25 18:12:19.653	\N	\N	2321f46b27af922eadefd44d130de4c809d29ea08865070a2350701772966475
e5b7ba4df9390e966c7c786f18ed217a	0	0	\N	部门管理 - PUT /api/v1/depts/e3c7a43c3bf49f56d6ab700e270e1114	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{},"body":{"departName":"成本组","parentId":"555f8f0307a3d92dfa3923b58889decb","departOrder":3,"description":"成本核算、预算控制"}}	\N	admin	2026-11-25 18:12:19.792	\N	\N	4b8904acae2583f360de2723634769bd1374f572c875a3e2c2573a6ccd29dc75
8697b209b1c75b1e955a33c51e803507	0	0	\N	部门管理 - PUT /api/v1/depts/4fa21fe679ec8a87f089a3f22302cbbb	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{},"body":{"departName":"用研组","parentId":"1577baeb20661e0ba522c60351c101b2","departOrder":3,"description":"用户调研、可用性测试"}}	\N	admin	2026-11-25 18:12:19.897	\N	\N	a4cb3d99253cf8a27dee8f3ebece14400307b607b0a4ae3033ab5fe910bc7698
6bf3570806f795ab6088407d37274b2a	0	0	\N	部门管理 - PUT /api/v1/depts/d03c1e5fa900c7cc374e215fc5aa03c4	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{},"body":{"departName":"前端组","parentId":"d3e1489934c2d5d5cf10e4cd614c4404","departOrder":1,"description":"Web/小程序前端"}}	\N	admin	2026-11-25 18:12:19.92	\N	\N	eb5ff8297d308e201b622fe11354a780293c84fd2ed2eaca4ec0753fd6dd03d2
0706ab8d4cb0f9866ee5f2adb3fd1595	0	0	\N	部门管理 - PUT /api/v1/depts/760de6f8fb3aa4be8e60358dfbf91fec	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{},"body":{"departName":"知识产权组","parentId":"531503f12d9cdf729d9ce8ae535ca6ab","departOrder":3,"description":"专利、商标、著作权"}}	\N	admin	2026-11-25 18:12:19.839	\N	\N	dd0742f6f0d14328ddf79fbbc76a33907a2f6a5583b40c82e6b95a1cfcf01fea
6a6b069fd7fbb3f7f6f9f80f95eb3554	0	0	\N	部门管理 - PUT /api/v1/depts/555f8f0307a3d92dfa3923b58889decb	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	5	\N	\N	\N	{"query":{},"body":{"departName":"财务部","parentId":null,"departOrder":4,"description":"会计核算、资金、报表、税务"}}	\N	admin	2026-11-25 18:12:19.752	\N	\N	181c0597210f6e162d27c56a98487a880d69a752d4769bace28870ec2432c065
d04be39c2aa25ef2ec7b4615fd4e62c6	0	0	\N	部门管理 - PUT /api/v1/depts/5be257cef78d16f621e7b86a0d646e0a	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{},"body":{"departName":"运维组","parentId":"d3e1489934c2d5d5cf10e4cd614c4404","departOrder":4,"description":"部署、监控、故障"}}	\N	admin	2026-11-25 18:12:19.977	\N	\N	66397d4cae40fcaeac691a9297d89734a120b64e9651190f03037e9e97ea5ec0
dd5ad93ac2289f1ad34aa19bf5beb943	0	0	\N	部门管理 - PUT /api/v1/depts/39d47b2eaa34dd6aaf2f4a77ff8b549d	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{},"body":{"departName":"品牌组","parentId":"5db52b767a1cbd831537d81976df3a95","departOrder":1,"description":"品牌定位、VI、公关"}}	\N	admin	2026-11-25 18:12:20.039	\N	\N	0be275a17d67e7e87a8873177dad275cf468e14617f0a2860f8936de4b53ba44
81bf69bbf26b1f34492929761bba1b98	0	0	\N	部门管理 - PUT /api/v1/depts/6cae4d898c1073b39b0b0ddd5364c928	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{},"body":{"departName":"销售部","parentId":null,"departOrder":9,"description":"签单、客户关系、回款"}}	\N	admin	2026-11-25 18:12:20.127	\N	\N	f8bafc97dd16bde9a3ec2a7dfc6df317bcc9a6dd6d232eb82a80dcb28f3bd411
32d3fd9fc41ace3c1af764d35393e5f6	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:44:26.306	\N	\N	639e2affb30a1df01afdbcbd650fac0ba66d795ba37c0ba96122d0192a02febb
90447ff5f86f0f42ee799f1db46fcee0	0	0	\N	部门管理 - PUT /api/v1/depts/2aa12fcceb1e0b9c21e35780242b8884	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{},"body":{"departName":"渠道组","parentId":"6cae4d898c1073b39b0b0ddd5364c928","departOrder":3,"description":"代理商、合作伙伴"}}	\N	admin	2026-11-25 18:12:20.181	\N	\N	c6ac3b5cd787bab4b1814550000b0ecd3c5f63db0d2dcf2ab208478d140c0c9e
143d7a0dbaced90ebae583dad38470c3	0	0	\N	部门管理 - PUT /api/v1/depts/5bbd2dc7daee73642b67585ec08c40ef	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{},"body":{"departName":"大客户组","parentId":"6cae4d898c1073b39b0b0ddd5364c928","departOrder":4,"description":"重点客户维护"}}	\N	admin	2026-11-25 18:12:20.204	\N	\N	eeea3a6987205a1f685cfeded01803161bed7700e072b0c3ecfb6602e4d3339a
28b05c486f9bfb3baba4854abe71c28a	0	0	\N	部门管理 - PUT /api/v1/depts/4e390600751ce578102a6d3903a7c2e8	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{},"body":{"departName":"活动组","parentId":"5db52b767a1cbd831537d81976df3a95","departOrder":4,"description":"展会、线上活动"}}	\N	admin	2026-11-25 18:12:20.112	\N	\N	73afb6897c12005e2caa44b83f18e1cba9aa51958939ee4fc05e21fdcc2524f8
03c80cab43812dcd300e9c06f6524623	0	0	\N	部门管理 - PUT /api/v1/depts/8ccf8ae1828c7c9f9b9933ff3590f674	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{},"body":{"departName":"会计组","parentId":"555f8f0307a3d92dfa3923b58889decb","departOrder":1,"description":"记账、报表、税务申报"}}	\N	admin	2026-11-25 18:12:19.768	\N	\N	1d5edfb0d9a00c02ae55981d71d02578427b9fbe5e35bbc0c4ca3d2bb5dd124b
22a5978ceacb55b50a1038f6e12d2289	0	0	\N	部门管理 - PUT /api/v1/depts/ec46d2554ec6745bd25c89eacbf2838f	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	11	\N	\N	\N	{"query":{},"body":{"departName":"出纳组","parentId":"555f8f0307a3d92dfa3923b58889decb","departOrder":2,"description":"收付款、银行、现金"}}	\N	admin	2026-11-25 18:12:19.781	\N	\N	b04886b596c435b48e7a15143cbc8d88085157d712da2f685a10e2bc820aa911
23c101dd5834fb843c5c66bd33ce2e78	0	0	\N	部门管理 - PUT /api/v1/depts/531503f12d9cdf729d9ce8ae535ca6ab	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	5	\N	\N	\N	{"query":{},"body":{"departName":"法务部","parentId":null,"departOrder":5,"description":"合同审核、合规、纠纷"}}	\N	admin	2026-11-25 18:12:19.802	\N	\N	737fe2dd0dd692f8a27cb49a8cbdde2ca2768aea15ee919d6b7a211fdb22e0fd
811554b6f34699938823a92bf236f038	0	0	\N	部门管理 - PUT /api/v1/depts/99a0d20e0d987922cf12a549625ad4a6	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{},"body":{"departName":"合同组","parentId":"531503f12d9cdf729d9ce8ae535ca6ab","departOrder":1,"description":"合同起草审核、归档"}}	\N	admin	2026-11-25 18:12:19.815	\N	\N	c31867bfaed26c43a4300554697df242584f5d9052fe2d7a7b0dcf22cfc58e2d
2939e527e9a7dde463ad516760e006f2	0	0	\N	部门管理 - PUT /api/v1/depts/d29d3723af11ad4111c67ad54fbcffef	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{},"body":{"departName":"合规组","parentId":"531503f12d9cdf729d9ce8ae535ca6ab","departOrder":2,"description":"法律风险、监管合规"}}	\N	admin	2026-11-25 18:12:19.829	\N	\N	52163148e746473510f5cb7217dc1d263338a0b6b7a4b57fa8e0c1cccf7901fb
c3c83d6c423f39c306bdcab3ca2764f4	0	0	\N	部门管理 - PUT /api/v1/depts/1577baeb20661e0ba522c60351c101b2	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	5	\N	\N	\N	{"query":{},"body":{"departName":"产品部","parentId":null,"departOrder":6,"description":"需求、原型、用户体验"}}	\N	admin	2026-11-25 18:12:19.85	\N	\N	cdb35eae6e608770b427320c65f7a8423c60cf24bcf1e023a9108877fbb1cfec
2f9a08dd832a6c9b2ccdbb17775655e2	0	0	\N	部门管理 - PUT /api/v1/depts/2128fcf7ff6c60920e2294e2b009b5ab	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	19	\N	\N	\N	{"query":{},"body":{"departName":"行政部","parentId":null,"departOrder":3,"description":"前台、办公环境、资产、车辆、接待"}}	\N	admin	2026-11-25 18:12:19.656	\N	\N	7d552b749167a129688e0cf4b00884a8356f19f81f283143ed00cf819fa80374
00dba97d80f521ab2a22ab1676120c88	0	0	\N	部门管理 - PUT /api/v1/depts/eccd62d7565486bec4bf7097af9e02ef	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{},"body":{"departName":"产品组","parentId":"1577baeb20661e0ba522c60351c101b2","departOrder":1,"description":"需求、原型、PRD"}}	\N	admin	2026-11-25 18:12:19.872	\N	\N	59a582a131654f4ba6c1dad0c6d09e004142128f1b047cb22f4d51634750c3cc
b94969648a9db9b99fbc6fe3d2848923	0	0	\N	部门管理 - PUT /api/v1/depts/d6233d450450a6fee112aa0d5bf5a111	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{},"body":{"departName":"设计组","parentId":"1577baeb20661e0ba522c60351c101b2","departOrder":2,"description":"UI/UX、视觉"}}	\N	admin	2026-11-25 18:12:19.883	\N	\N	766ef8f7b54e44068f1e423a0978651979e17181f980492aea8e10d8174a5ffe
fba2224aab293ab6b098e970e54f3bb4	0	0	\N	部门管理 - PUT /api/v1/depts/1fb4b0372ab1925f031895b23f3440b4	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{},"body":{"departName":"数据组","parentId":"d3e1489934c2d5d5cf10e4cd614c4404","departOrder":5,"description":"数据仓库、BI"}}	\N	admin	2026-11-25 18:12:19.999	\N	\N	783934e1aad3b6bfb5d6b50b03e7586c53a4cbc145fc23b5c1fcd57f451673cd
6bd16d74782e1542d2e96c1318d96839	0	0	\N	部门管理 - PUT /api/v1/depts/5db52b767a1cbd831537d81976df3a95	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	6	\N	\N	\N	{"query":{},"body":{"departName":"市场部","parentId":null,"departOrder":8,"description":"品牌、推广、获客"}}	\N	admin	2026-11-25 18:12:20.018	\N	\N	a018bfa257418a8a487e4b381d977d11f2aaf0eb0ba212ae6ae6ecfbb932df48
ead1539b2a272551de134d3d557178ef	0	0	\N	部门管理 - PUT /api/v1/depts/38597acb8e812274d601af864c1e6c5a	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	133	\N	\N	\N	{"query":{},"body":{"departName":"督办组","parentId":"af598343d6bd897baa306c5489790bc7","departOrder":2,"description":"决议跟踪、跨部门协调"}}	\N	admin	2026-11-25 18:12:19.653	\N	\N	37204d17ea388447fee5604830bd42756519f3e9c8288a6e137616444ac0ff64
6e50fc87a9043b0ac27a4b1efdf2208b	0	0	\N	部门管理 - PUT /api/v1/depts/18beed4df928b66aa37e54196b867101	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	11	\N	\N	\N	{"query":{},"body":{"departName":"内容组","parentId":"5db52b767a1cbd831537d81976df3a95","departOrder":3,"description":"文案、新媒体、素材"}}	\N	admin	2026-11-25 18:12:20.088	\N	\N	2fd4f298ad937f8a879969517e9ce06c3933e69d02e00a8638ce1d064bd3fbe1
3bf3ce99b43f97fecc6e8d123b564abb	0	0	\N	部门管理 - PUT /api/v1/depts/d3e1489934c2d5d5cf10e4cd614c4404	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	5	\N	\N	\N	{"query":{},"body":{"departName":"技术部","parentId":null,"departOrder":7,"description":"研发、测试、运维"}}	\N	admin	2026-11-25 18:12:19.903	\N	\N	bb9a4ccf549a54c7d810eea99cf8dbcba139a25206aa07d6ff85ad00ffad61a3
172cc72fd93e84061c5a53af06ebf8c6	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	11	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:45:24.147	\N	\N	b727adfa256e509f43f97983e0fe18f4d36f2cea5b598437918a6d569ede4a82
b7852f23b5dbb4b4e6a6aa93a53c7ac2	0	0	\N	部门管理 - PUT /api/v1/depts/b901fdcf1f05ef030a4d8611e34c8884	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{},"body":{"departName":"后端组","parentId":"d3e1489934c2d5d5cf10e4cd614c4404","departOrder":2,"description":"接口、数据、服务"}}	\N	admin	2026-11-25 18:12:19.942	\N	\N	6a46fd4a8cdfa30a0b9aba6ec2ba1b9de858e53d8daf25e779ed99b6c6d35cf4
8c488c2a2c18354cccc3836a7480a573	0	0	\N	部门管理 - PUT /api/v1/depts/416253c3de1187227e36288a728eb1e0	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	137	\N	\N	\N	{"query":{},"body":{"departName":"战略组","parentId":"af598343d6bd897baa306c5489790bc7","departOrder":1,"description":"规划、经营分析"}}	\N	admin	2026-11-25 18:12:19.654	\N	\N	4f173d62acfbfc25b2537e05627ca980c7de2c432ba774a1bae15c58c7da4d3e
4d89dc4c559e46e2943ba141d3a0e3d3	0	0	\N	部门管理 - PUT /api/v1/depts/f026194db425743c7cd02d3ed50deb67	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	6	\N	\N	\N	{"query":{},"body":{"departName":"运营部","parentId":null,"departOrder":10,"description":"用户、内容、数据运营"}}	\N	admin	2026-11-25 18:12:20.225	\N	\N	48764b55b8e49513c6ab6b3866a48b31aed8c5f252c6d08591b33d4a873c25af
c8f007d6410bb6044d715980ab5f5daf	0	0	\N	部门管理 - PUT /api/v1/depts/4c5e87295e51cacc865bf92accb55875	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{},"body":{"departName":"用户运营","parentId":"f026194db425743c7cd02d3ed50deb67","departOrder":1,"description":"拉新、留存、社群"}}	\N	admin	2026-11-25 18:12:20.238	\N	\N	e8514e9698b82003ce03bb03876ca3356ffc315e53dca3dc16792027f944790f
37f7527802026b488a0efc8978e46de9	0	0	\N	部门管理 - PUT /api/v1/depts/55d28a2e23ee0d540765d6f275c137e1	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{},"body":{"departName":"销售一组","parentId":"6cae4d898c1073b39b0b0ddd5364c928","departOrder":1,"description":"销售一组"}}	\N	admin	2026-11-25 18:12:20.148	\N	\N	6e3753f90ac9bba1daa1baa9860a9a682fbc5f23091043aa066abe609e66f57e
dfbdbfc5f0272ec46747db43de2b6f7e	0	0	\N	部门管理 - PUT /api/v1/depts/64ebf0a472bdb5fe68c96b693bbd27f4	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{},"body":{"departName":"推广组","parentId":"5db52b767a1cbd831537d81976df3a95","departOrder":2,"description":"投放、渠道获客"}}	\N	admin	2026-11-25 18:12:20.06	\N	\N	248a7c63f839dc805c2a9a3ed3de2e20ff1f3c2f0ca4fbbe4db6017a4a86d9df
8ec4c872f44c6a326b66db09d0a2e1da	0	0	\N	部门管理 - PUT /api/v1/depts/0805397fc9ee27797f78e7f0e517fcdb	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{},"body":{"departName":"测试组","parentId":"d3e1489934c2d5d5cf10e4cd614c4404","departOrder":3,"description":"功能/自动化测试"}}	\N	admin	2026-11-25 18:12:19.963	\N	\N	ad9b472b52accf3b02f8f260c5a37dfe2c7a2ba6466476c6e8aec29a254582ab
ca0f1714e66b42543eb3afda9da791bc	0	0	\N	部门管理 - PUT /api/v1/depts/b92d77cc5bb247bc30ecd8af790219df	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{},"body":{"departName":"销售二组","parentId":"6cae4d898c1073b39b0b0ddd5364c928","departOrder":2,"description":"销售二组"}}	\N	admin	2026-11-25 18:12:20.166	\N	\N	c159cc16aab25e81a63ed10997a28ff7f24cae521bbd3bb571c5667fea361e3d
aede29735125094a722b42bcd32bed08	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:12:24.03	\N	\N	51e2e994c7e6bbf1025d95419a1c398e89ebbfb96eeec66614a51acf114a1da3
e9f47878ca2ec7be6405b9570270370b	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	1	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:12:24.068	\N	\N	4feff91d9a7ac6e70ca3acc25ec7ab2d2660a021c424c44de25ff29424bbaca4
517c34b0bd24e4a3324b3b4a6901152f	0	0	\N	部门管理 - PUT /api/v1/depts/bdd29ce3d7f07a087f73ee2aced413f2	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	79	\N	\N	\N	{"query":{},"body":{"departName":"内容运营","parentId":"f026194db425743c7cd02d3ed50deb67","departOrder":2,"description":"内容生产、审核"}}	\N	admin	2026-11-25 18:12:36.856	\N	\N	842363cf1ad8448350b460834be0b904ad3e8b06aa8eb3919a92d5eef6e7d216
ea66bf3f9687ad3d1c878f2808e24ac7	0	0	\N	部门管理 - PUT /api/v1/depts/4c5e87295e51cacc865bf92accb55875	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	14	\N	\N	\N	{"query":{},"body":{"departName":"用户运营","parentId":"f026194db425743c7cd02d3ed50deb67","orgCode":"OPS_USER","orgCategory":"2","departOrder":0,"status":"1","description":"拉新、留存、社群"}}	\N	admin	2026-11-25 18:12:47.421	\N	\N	d69e6207b32876f0556c0989b6371bda3f816cc7bcac83b12defbef327240ea7
22c5ac2ad35d013a5cf78e4fa95221fd	0	0	\N	部门管理 - PUT /api/v1/depts/bdd29ce3d7f07a087f73ee2aced413f2	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	13	\N	\N	\N	{"query":{},"body":{"departName":"内容运营","parentId":"f026194db425743c7cd02d3ed50deb67","orgCode":"OPSA02","orgCategory":"2","departOrder":1,"status":"1","description":"内容生产、审核"}}	\N	admin	2026-11-25 18:12:53.091	\N	\N	9d7818cff0d7fb7c4ba3f041c76051e116b0d9a8835ed17ff49b295c7b130ad1
5c3e80dd8df915484ba49a40b08ebd79	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	11	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:51:29.349	\N	\N	138627858ca0011a66911abcfe6b77f8127ee8cbc42465f3d6e28ecd1b3cc5c7
b2f0b786b9922575f05ced64ce7e441f	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	11	\N	\N	\N	{"query":{},"body":{"departName":"数据运营","parentId":"f026194db425743c7cd02d3ed50deb67","orgCode":"OPS_DATA","orgCategory":"2","departOrder":2,"status":"1","description":"指标、分析、增长实验"}}	\N	admin	2026-11-25 18:13:11.722	\N	\N	f029a32efafef16e2db270f8db894be3268011a66867f5aa31d3888b7c00a8f0
06377430c999b43a8023d8b546ef5fb7	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	61	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:13:24.056	\N	\N	de1b16cd18d8c31f52d6719e19dbe15987a00110735ab7944323d99d5aba3041
1b334993ff1d2b998f8a846c972733b3	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	6	\N	\N	\N	{"query":{},"body":{"departName":"活动运营","parentId":"f026194db425743c7cd02d3ed50deb67","orgCode":"OPS_EVENT","orgCategory":"2","departOrder":3,"status":"1","description":"促销活动策划"}}	\N	admin	2026-11-25 18:13:32.743	\N	\N	873c7b129b4eb080e1dcd0859d28a9f097f64d22e1652bcc8a36cbb9c59fb7c9
1e468d8d5032a8e9f378fa46e2452ab6	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	66	\N	\N	\N	{"query":{},"body":{"departName":"售前支持","parentId":"fd6753b0084a2074f64f6c3bab3ff032","orgCode":"CS_PRE","orgCategory":"2","departOrder":0,"status":"1","description":"咨询、报价、方案"}}	\N	admin	2026-11-25 18:13:52.222	\N	\N	3e28bb75d3a8a73b276eb7b673bc1b4d1e9a87a893cc7ec5a5844ba45b8d5642
cae73bbbe433c5e38a10611cb6aa296a	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	11	\N	\N	\N	{"query":{},"body":{"departName":"售后支持","parentId":"fd6753b0084a2074f64f6c3bab3ff032","orgCode":"CS_POST","orgCategory":"2","departOrder":1,"status":"1","description":"工单、退换、投诉"}}	\N	admin	2026-11-25 18:14:08.409	\N	\N	29e3c4c2136af7a65874fad208c25b7d7bfc0053c470bcf310b92eae710b396e
a49b0bd5dd6cd016a1de8f899ca6f160	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	77	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:14:24.108	\N	\N	e0140b66de4360d4596988d64fd66664de9705999bd45ddbc844ffbb753450c8
9784eba489274231d4ee5d3e1a1c5969	0	0	\N	部门管理 - PUT /api/v1/depts/af598343d6bd897baa306c5489790bc7	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	16	\N	\N	\N	{"query":{},"body":{"departName":"总经办1","parentId":null,"orgCode":"GM_OFFICE","orgCategory":"2","departOrder":1,"status":"1","description":"决策辅助、文件流转、高层日程"}}	\N	admin	2026-11-25 18:14:41.953	\N	\N	66437e693d229f3913933562a6fb92faf8bd352c83d27324d6eaad2fb924a0de
ee7ebeceaee7b63e143b6df9bceff6c0	0	0	\N	部门管理 - PUT /api/v1/depts/af598343d6bd897baa306c5489790bc7	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{},"body":{"departName":"总经办","parentId":null,"orgCode":"GM_OFFICE","orgCategory":"2","departOrder":1,"status":"1","description":"决策辅助、文件流转、高层日程"}}	\N	admin	2026-11-25 18:14:46.843	\N	\N	f0992ce42db26586a7e5f7fb816a404e4392ee136b70078e1b99294b0742cf2d
4fa7a4455b34873c9b52b457dfab3885	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	70	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:15:24.082	\N	\N	6155ebad7036e65578ef252f238e7d215acd1d2d78a29daf054e45975dd355e7
472d0776a13d8ef8abaacd71432ee5ae	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	62	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:16:24.243	\N	\N	e090d3008b1f3422749b34ae9f89da07a8dc1a15f701a0c3d6de69012a6ca4d4
4cd5bd2b15b3a0227ad1af8fc15d272d	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	11	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:17:24.313	\N	\N	ae2919f7e818d98f57ceb6bd885bb9da23fd644f701d795f9c2da1e1d19a7e91
21f2c40fed0de51e63e1d921c2aed1cc	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:18:24.274	\N	\N	8edaa88bef6d6104e315b5fb5546a2a9338b3aec4a3329fff04a349edf4d928f
44fa5a4a8620a2412301e125f9dea2d9	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:19:34.281	\N	\N	8bfed69323248de2fb372279779593d48b406b96e03f3ff85cd28cc65b95d34d
cf20e11abccdbf729055a0be5f06339f	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:20:34.299	\N	\N	d2115f04ebef8ccc3738c5640290ee702f87439b221f5b7eda8ac48eb8859395
b72a3afdf9553bde772d8c0057b1c5cd	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:21:34.295	\N	\N	8d3bd32ad8aede81c5e30eb08a3cec29fd8ae255d8674b8964c30deae50bb43e
b5a1718738c11d8ea125fe96c36cb81c	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	11	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:22:34.301	\N	\N	16a852719e1c16cd3a3aab60179b07c7a751adbdb3b26b185994e8f39012bb70
e980709b8ccf6e01740a6d2f04c5eddf	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:23:34.288	\N	\N	f6446f76e212ccfe6c7154886b370e64d1762aa71255bcdd508ba5527b2fbc08
b1a97c7e898a111772634df40280d17c	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:24:34.291	\N	\N	ff672afd307988db864ebe52ac79677421cf00d58fc9ab7d9e3240dda75ca8af
ead31cae0ff39be58ca796ab5cedf916	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:25:24.127	\N	\N	301d0c68d96834b9373e186913b30968e4dac646ac7022b90cad1ac37632b6bc
7c3412a14dce748d484c6869ae6d9e6a	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	72	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:28:24.071	\N	\N	5dc1c1be6e78a5a7916f56c858391df5ba4467bc27dc7d78dfaead78eb5676c7
d9b81609c64228938c7cab1c3f041d96	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:29:24.298	\N	\N	c0d82040e87817182be399bb2347787e619e6580dcae845768ae3c3fcc524a1a
66d2f3def07497c6c96030ca87edccc1	0	0	\N	部门管理 - POST /api/v1/depts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{},"body":{"departName":"ConciseAdmin科技","parentId":null,"orgCode":"CAKJ","orgCategory":"1","departOrder":0,"status":"1","description":null}}	\N	admin	2026-11-25 18:29:51.535	\N	\N	0a4b3b65caf64786e180e6c62bf97b24b0401cb86867af5deacffa55d995db0f
e3536307dd2c62f652bc616985ef38f5	0	0	\N	部门管理 - PUT /api/v1/depts/2756c6363bd77819291b0e003c019dd1	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	20	\N	\N	\N	{"query":{},"body":{"departName":"ConciseAdmin科技","parentId":null,"departOrder":1,"description":null}}	\N	admin	2026-11-25 18:30:02.148	\N	\N	0f08f2041f370e60b511b7d8c7784be418f91c0791e86441c08d7ec127f34079
cd1b1332225e89027811bf1a295ec49b	0	0	\N	部门管理 - PUT /api/v1/depts/7d1f963d67dfe200572b8a84f6f1afa7	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{},"body":{"departName":"售前支持","parentId":"fd6753b0084a2074f64f6c3bab3ff032","departOrder":1,"description":"咨询、报价、方案"}}	\N	admin	2026-11-25 18:30:02.175	\N	\N	b4fee3a6311c24aab2efa00d0687ce7e3cd616fe1fde9dfcac577f5633327b5e
980c493eb04af7fc7a90f7ed3800833e	0	0	\N	部门管理 - PUT /api/v1/depts/fad47f8b8a28490abed1f058bf24c164	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{},"body":{"departName":"售后支持","parentId":"fd6753b0084a2074f64f6c3bab3ff032","departOrder":2,"description":"工单、退换、投诉"}}	\N	admin	2026-11-25 18:30:02.2	\N	\N	1b612438054971e9339e06d87fb3a5697bd25a1c79309548372b6b2d2b23308a
30d411f1fd9213c06018a28314aca036	0	0	\N	部门管理 - PUT /api/v1/depts/bdd29ce3d7f07a087f73ee2aced413f2	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	21	\N	\N	\N	{"query":{},"body":{"departName":"内容运营","parentId":"f026194db425743c7cd02d3ed50deb67","departOrder":2,"description":"内容生产、审核"}}	\N	admin	2026-11-25 18:30:02.148	\N	\N	28c4159594ae8a1c917748d08b80b8484e3ce6688f17c5e74ea156c3074db7d4
db782bef9e55bef59529cb715f6f4906	0	0	\N	部门管理 - PUT /api/v1/depts/4c5e87295e51cacc865bf92accb55875	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	22	\N	\N	\N	{"query":{},"body":{"departName":"用户运营","parentId":"f026194db425743c7cd02d3ed50deb67","departOrder":1,"description":"拉新、留存、社群"}}	\N	admin	2026-11-25 18:30:02.149	\N	\N	2eb4e6a95364b52978b2661b88d886297f4bc38f0c2076e81e90f0bc2fb69880
2e443645a07724f058a990fe4f93cd05	0	0	\N	部门管理 - PUT /api/v1/depts/94d2d903b59374c16e5244fa9641d8cd	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	22	\N	\N	\N	{"query":{},"body":{"departName":"数据运营","parentId":"f026194db425743c7cd02d3ed50deb67","departOrder":3,"description":"指标、分析、增长实验"}}	\N	admin	2026-11-25 18:30:02.149	\N	\N	1fdc2a2a26823dd396e169b9683b7b0132303a140ef06aa8d3d994d5adb16c02
5ca5ace739c705098b1c5db8461b0f38	0	0	\N	部门管理 - PUT /api/v1/depts/da5ae3b0afa3a7685e2d62273306b665	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	23	\N	\N	\N	{"query":{},"body":{"departName":"活动运营","parentId":"f026194db425743c7cd02d3ed50deb67","departOrder":4,"description":"促销活动策划"}}	\N	admin	2026-11-25 18:30:02.15	\N	\N	6c7ef8b918df7b081d6d60f631282ea8290e5086fba7136ed85ceef33402e63b
af6c708ad5f02e2726d4bb2357c7c071	0	0	\N	部门管理 - PUT /api/v1/depts/af598343d6bd897baa306c5489790bc7	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	25	\N	\N	\N	{"query":{},"body":{"departName":"总经办","parentId":"2756c6363bd77819291b0e003c019dd1","departOrder":1,"description":"决策辅助、文件流转、高层日程"}}	\N	admin	2026-11-25 18:30:02.151	\N	\N	e8f5f759c6d2eda1cb5ee48e939dc2f566d34389d4e98e923cda4e522404d9db
b6c466669583b8c51200e51d222adfa0	0	0	\N	部门管理 - PUT /api/v1/depts/2128fcf7ff6c60920e2294e2b009b5ab	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	17	\N	\N	\N	{"query":{},"body":{"departName":"行政部","parentId":null,"departOrder":2,"description":"前台、办公环境、资产、车辆、接待"}}	\N	admin	2026-11-25 18:30:04.695	\N	\N	4155ea7f49b4c65ce5f83750e85915cbc7529bbcbaab8a583af7b9f4835e921d
8a3b474417a45628a5de283f57d41ce1	0	0	\N	部门管理 - PUT /api/v1/depts/5db52b767a1cbd831537d81976df3a95	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{},"body":{"departName":"市场部","parentId":null,"departOrder":7,"description":"品牌、推广、获客"}}	\N	admin	2026-11-25 18:30:04.728	\N	\N	8cb2090891dbb87de3580cb4bfd2ddfc720c1cdfbc16d1ddec03fd6cbb055c74
6158b1accc43be335ad66d6323928b47	0	0	\N	部门管理 - PUT /api/v1/depts/6cae4d898c1073b39b0b0ddd5364c928	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{},"body":{"departName":"销售部","parentId":null,"departOrder":8,"description":"签单、客户关系、回款"}}	\N	admin	2026-11-25 18:30:04.752	\N	\N	46e8b23d6d84263f9bca6dedce63a015e30ffe59fbb1f93a7206b1e90c298e3b
8da6ecc092513c7eaab15b249679d765	0	0	\N	部门管理 - PUT /api/v1/depts/f026194db425743c7cd02d3ed50deb67	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	6	\N	\N	\N	{"query":{},"body":{"departName":"运营部","parentId":null,"departOrder":9,"description":"用户、内容、数据运营"}}	\N	admin	2026-11-25 18:30:04.776	\N	\N	d0e6d39883026c7909a1738d58039b24e56d116797157b12eeb2975e53291a0f
60eb8b22d0ec899cf16dc148e73a1783	0	0	\N	部门管理 - PUT /api/v1/depts/fd6753b0084a2074f64f6c3bab3ff032	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{},"body":{"departName":"客服部","parentId":null,"departOrder":10,"description":"售前咨询、售后支持"}}	\N	admin	2026-11-25 18:30:04.798	\N	\N	2918d189513cdfecc6a206bf4f612c976ae30a515065f34db991e4136bf8712e
7eae5517276ac2ec25bf97e698e38914	0	0	\N	部门管理 - PUT /api/v1/depts/1577baeb20661e0ba522c60351c101b2	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	23	\N	\N	\N	{"query":{},"body":{"departName":"产品部","parentId":null,"departOrder":5,"description":"需求、原型、用户体验"}}	\N	admin	2026-11-25 18:30:04.704	\N	\N	236cbb4de0e710c50c52a677c21495652938d3bbea7a1060393d950f9d2e8d90
d62216e01a21d55fd553acc3009873b8	0	0	\N	部门管理 - PUT /api/v1/depts/555f8f0307a3d92dfa3923b58889decb	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	17	\N	\N	\N	{"query":{},"body":{"departName":"财务部","parentId":null,"departOrder":3,"description":"会计核算、资金、报表、税务"}}	\N	admin	2026-11-25 18:30:04.697	\N	\N	76c153b48b71d4ca80013a07773adaffafcb82e99fea1df287aefb684cdceecf
8c7fbb4a44aa90ce8397ccf934daecc7	0	0	\N	部门管理 - PUT /api/v1/depts/531503f12d9cdf729d9ce8ae535ca6ab	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	21	\N	\N	\N	{"query":{},"body":{"departName":"法务部","parentId":null,"departOrder":4,"description":"合同审核、合规、纠纷"}}	\N	admin	2026-11-25 18:30:04.702	\N	\N	aed4e89c6e40c66dfb25a9a5d201aeff559534cc8c728574904bdb0ec9d10ebb
eed13e343d235176f0a60ac711a1ffd3	0	0	\N	部门管理 - PUT /api/v1/depts/d3e1489934c2d5d5cf10e4cd614c4404	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	24	\N	\N	\N	{"query":{},"body":{"departName":"技术部","parentId":null,"departOrder":6,"description":"研发、测试、运维"}}	\N	admin	2026-11-25 18:30:04.705	\N	\N	f4d2882f613e889af81c86e2c4a982ea50efd919bf51763025757f9637697e09
4c7c83b502dcac510c5b6ae2b35cd0ac	0	0	\N	部门管理 - PUT /api/v1/depts/064719832c25df4ba5f58bfbf8872284	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	33	\N	\N	\N	{"query":{},"body":{"departName":"人力资源部","parentId":"2756c6363bd77819291b0e003c019dd1","departOrder":2,"description":"招聘、薪酬、绩效、培训"}}	\N	admin	2026-11-25 18:30:04.711	\N	\N	7b06e3d4b6012730dc3a6ae55d9bf6c35711b78558f0bff3998e3259f9258091
cb29529c2f47a601480f867ab6ab3021	0	0	\N	部门管理 - PUT /api/v1/depts/555f8f0307a3d92dfa3923b58889decb	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	13	\N	\N	\N	{"query":{},"body":{"departName":"财务部","parentId":null,"departOrder":2,"description":"会计核算、资金、报表、税务"}}	\N	admin	2026-11-25 18:30:06.693	\N	\N	e7562a65afa9bf9c44df8c968d6197ddfac69353621b771251118a8ecd8bb8f5
44167adbb0e5639133da4a4df16913e3	0	0	\N	部门管理 - PUT /api/v1/depts/6cae4d898c1073b39b0b0ddd5364c928	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	5	\N	\N	\N	{"query":{},"body":{"departName":"销售部","parentId":null,"departOrder":7,"description":"签单、客户关系、回款"}}	\N	admin	2026-11-25 18:30:06.717	\N	\N	ecdd14b58ea440124cd6737f7ca5732e02e4ba4947beb53d28cc4210dcae515b
539e5f98049796b2572cf87530c512df	0	0	\N	部门管理 - PUT /api/v1/depts/f026194db425743c7cd02d3ed50deb67	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{},"body":{"departName":"运营部","parentId":null,"departOrder":8,"description":"用户、内容、数据运营"}}	\N	admin	2026-11-25 18:30:06.741	\N	\N	e5779b6ae553e2821f5ffb30a37434254ffb9a531a52ef673e14ede9340c1f11
79f03c7d0e199b6831727e4b80daf435	0	0	\N	部门管理 - PUT /api/v1/depts/fd6753b0084a2074f64f6c3bab3ff032	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{},"body":{"departName":"客服部","parentId":null,"departOrder":9,"description":"售前咨询、售后支持"}}	\N	admin	2026-11-25 18:30:06.763	\N	\N	9380fbbb74ce24bc4815a091ff43bb424fb3576308855825a2cfca2fdf3614aa
06cd25b9412a3c81f2c39deeeb654b02	0	0	\N	部门管理 - PUT /api/v1/depts/531503f12d9cdf729d9ce8ae535ca6ab	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	14	\N	\N	\N	{"query":{},"body":{"departName":"法务部","parentId":null,"departOrder":3,"description":"合同审核、合规、纠纷"}}	\N	admin	2026-11-25 18:30:06.694	\N	\N	585836b6326642e8a31c92debf851f44791e722abdedc4691d4189cabf8cd2de
a995afadeee75c03f3b8b7caefe24ac6	0	0	\N	部门管理 - PUT /api/v1/depts/1577baeb20661e0ba522c60351c101b2	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	13	\N	\N	\N	{"query":{},"body":{"departName":"产品部","parentId":null,"departOrder":4,"description":"需求、原型、用户体验"}}	\N	admin	2026-11-25 18:30:06.695	\N	\N	a5fa5acf733ff6d5de625681f72b4fd9f7b86fd89fc2dedca0933600bdeec05b
df0b2fc7edae7f0f92aae87fdbacc529	0	0	\N	部门管理 - PUT /api/v1/depts/d3e1489934c2d5d5cf10e4cd614c4404	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	14	\N	\N	\N	{"query":{},"body":{"departName":"技术部","parentId":null,"departOrder":5,"description":"研发、测试、运维"}}	\N	admin	2026-11-25 18:30:06.696	\N	\N	0113ecdc036d2d46eb8665007e1d8a4f66cc3e5fd11b2c7a27ca7e9e26bc4de7
2e6b6dadb986fbc3b3b67619eca812e4	0	0	\N	部门管理 - PUT /api/v1/depts/5db52b767a1cbd831537d81976df3a95	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	13	\N	\N	\N	{"query":{},"body":{"departName":"市场部","parentId":null,"departOrder":6,"description":"品牌、推广、获客"}}	\N	admin	2026-11-25 18:30:06.696	\N	\N	eac32ec971beab733c69426f9358f277f5315793ee8e2ce195329e8e7cc24226
c0ae6f75933413d7e3d42010f78f6cc5	0	0	\N	部门管理 - PUT /api/v1/depts/2128fcf7ff6c60920e2294e2b009b5ab	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	21	\N	\N	\N	{"query":{},"body":{"departName":"行政部","parentId":"2756c6363bd77819291b0e003c019dd1","departOrder":3,"description":"前台、办公环境、资产、车辆、接待"}}	\N	admin	2026-11-25 18:30:06.701	\N	\N	50aa0c01fc08ad695cba628fa35c3ab60e57f0cb7d93c8cddd6385bc490f5b0c
cf9065ee304c58e61729d032d9a8388b	0	0	\N	部门管理 - PUT /api/v1/depts/555f8f0307a3d92dfa3923b58889decb	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	35	\N	\N	\N	{"query":{},"body":{"departName":"财务部","parentId":"2756c6363bd77819291b0e003c019dd1","departOrder":4,"description":"会计核算、资金、报表、税务"}}	\N	admin	2026-11-25 18:30:08.311	\N	\N	cd03b5d2bcaa8b2a0c047bd223e1c36d123273ce96fd12b82ee9f3223442cc49
4005d7a9684c678c7b3a38acade0bb0e	0	0	\N	部门管理 - PUT /api/v1/depts/d3e1489934c2d5d5cf10e4cd614c4404	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	14	\N	\N	\N	{"query":{},"body":{"departName":"技术部","parentId":null,"departOrder":2,"description":"研发、测试、运维"}}	\N	admin	2026-11-25 18:30:11.729	\N	\N	6d9d1adf20d2639d8a20768a0a11438cd07bc46b92c8321861eb02d014d4d887
5cdfa4cb00b98bf4334229847f39f6eb	0	0	\N	部门管理 - PUT /api/v1/depts/fd6753b0084a2074f64f6c3bab3ff032	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	16	\N	\N	\N	{"query":{},"body":{"departName":"客服部","parentId":null,"departOrder":6,"description":"售前咨询、售后支持"}}	\N	admin	2026-11-25 18:30:11.735	\N	\N	f8a7a037e43fe9696f2ad98fea8b735e097c7ba7b5d8d09c317a05d86df5c576
c16c9d837b5acf54859ae0fa1f4e9aca	0	0	\N	部门管理 - PUT /api/v1/depts/5db52b767a1cbd831537d81976df3a95	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	21	\N	\N	\N	{"query":{},"body":{"departName":"市场部","parentId":null,"departOrder":3,"description":"品牌、推广、获客"}}	\N	admin	2026-11-25 18:30:11.736	\N	\N	c53f56cfb261ea8d9a9ca09610bd24342281fd60386666d969aa8e6be7b218d6
e51506af72a9d37351a5ac5b6f89e519	0	0	\N	部门管理 - PUT /api/v1/depts/d3e1489934c2d5d5cf10e4cd614c4404	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	14	\N	\N	\N	{"query":{},"body":{"departName":"技术部","parentId":null,"departOrder":4,"description":"研发、测试、运维"}}	\N	admin	2026-11-25 18:30:08.29	\N	\N	1d381e16640d97ad825cbc735f45f31beb60e081fc83c0b78b4536103c900eea
2c64b7b5613c8aa707fe28e15ac0f790	0	0	\N	部门管理 - PUT /api/v1/depts/fd6753b0084a2074f64f6c3bab3ff032	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	5	\N	\N	\N	{"query":{},"body":{"departName":"客服部","parentId":null,"departOrder":8,"description":"售前咨询、售后支持"}}	\N	admin	2026-11-25 18:30:08.334	\N	\N	b488e544a718e8efae022ec96b14a50ae80d070b2181f3c15d50fdcbdeeb46b4
625b2397dd87fd3a00fe5f696dbebfd1	0	0	\N	部门管理 - PUT /api/v1/depts/531503f12d9cdf729d9ce8ae535ca6ab	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	21	\N	\N	\N	{"query":{},"body":{"departName":"法务部","parentId":null,"departOrder":2,"description":"合同审核、合规、纠纷"}}	\N	admin	2026-11-25 18:30:08.298	\N	\N	f412df2da26cdd08eb372fb2eaa55cc9a56c9ab24ef4ce51c8733d86855b1508
d45f4400fa509a25ec654d183a244dad	0	0	\N	部门管理 - PUT /api/v1/depts/f026194db425743c7cd02d3ed50deb67	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	6	\N	\N	\N	{"query":{},"body":{"departName":"运营部","parentId":null,"departOrder":7,"description":"用户、内容、数据运营"}}	\N	admin	2026-11-25 18:30:08.319	\N	\N	44c185654ce13654419277f9a85af4619d0deca0cdaad0c9ea171a74480fc8b5
19d41de9dc8c5d46cd1a35f5346e2536	0	0	\N	部门管理 - PUT /api/v1/depts/1577baeb20661e0ba522c60351c101b2	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	22	\N	\N	\N	{"query":{},"body":{"departName":"产品部","parentId":null,"departOrder":3,"description":"需求、原型、用户体验"}}	\N	admin	2026-11-25 18:30:08.298	\N	\N	bd60459befede6820fe88189632d8af9f3d932aeeed357bdfb9e863f43201496
f1a89f11221e0aceb90f90371f70b792	0	0	\N	部门管理 - PUT /api/v1/depts/5db52b767a1cbd831537d81976df3a95	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	19	\N	\N	\N	{"query":{},"body":{"departName":"市场部","parentId":null,"departOrder":5,"description":"品牌、推广、获客"}}	\N	admin	2026-11-25 18:30:08.298	\N	\N	6cdb8e8ab4dc8428a8dccb036959ca4e31ee026932e869bcff1249eb4491ab44
7883e6a6c6ee789d62182f6f70f14bb7	0	0	\N	部门管理 - PUT /api/v1/depts/6cae4d898c1073b39b0b0ddd5364c928	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	18	\N	\N	\N	{"query":{},"body":{"departName":"销售部","parentId":null,"departOrder":6,"description":"签单、客户关系、回款"}}	\N	admin	2026-11-25 18:30:08.299	\N	\N	2690c96f0756b7c4737566344e5c7c215ea77b7c85e45f42fbda83f174bba24f
592e7de22c5e1cc59ed8615b036d3af6	0	0	\N	部门管理 - PUT /api/v1/depts/1577baeb20661e0ba522c60351c101b2	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{},"body":{"departName":"产品部","parentId":null,"departOrder":2,"description":"需求、原型、用户体验"}}	\N	admin	2026-11-25 18:30:10.247	\N	\N	b70f1b7157658c34f45e7d52224928ab6751b499196e93f4831e720dbd0886bf
d051b97ecd7095544c6f23163885f8f8	0	0	\N	部门管理 - PUT /api/v1/depts/fd6753b0084a2074f64f6c3bab3ff032	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{},"body":{"departName":"客服部","parentId":null,"departOrder":7,"description":"售前咨询、售后支持"}}	\N	admin	2026-11-25 18:30:10.273	\N	\N	71bd590b0e1ab041d160fdba1d02f76f0665602f938f0cbd116cb408ea603086
992e3bdc9d8acd3376a9db2fced6cbc8	0	0	\N	部门管理 - PUT /api/v1/depts/6cae4d898c1073b39b0b0ddd5364c928	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{},"body":{"departName":"销售部","parentId":null,"departOrder":5,"description":"签单、客户关系、回款"}}	\N	admin	2026-11-25 18:30:10.248	\N	\N	1a65af3db8de649eca80d56cd66d9be3dce9515bfa534f04ef0e26534db2f36c
6b293db6346ff1d7ef0adcc98d9b1d71	0	0	\N	部门管理 - PUT /api/v1/depts/d3e1489934c2d5d5cf10e4cd614c4404	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	12	\N	\N	\N	{"query":{},"body":{"departName":"技术部","parentId":null,"departOrder":3,"description":"研发、测试、运维"}}	\N	admin	2026-11-25 18:30:10.249	\N	\N	d303cdf6b8ad551a95d697d8c6dae7b6bdc2cff7f60eef0c2af5c39e2d6fdd3e
01a73f18f96ca8a4a119400c173b4e21	0	0	\N	部门管理 - PUT /api/v1/depts/5db52b767a1cbd831537d81976df3a95	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	11	\N	\N	\N	{"query":{},"body":{"departName":"市场部","parentId":null,"departOrder":4,"description":"品牌、推广、获客"}}	\N	admin	2026-11-25 18:30:10.249	\N	\N	045044473c3108e286457851ccedc2a69f255185780a8bc85bf3dbb6b1722912
a2efcf7d0e8ff45938c058713a0de0c5	0	0	\N	部门管理 - PUT /api/v1/depts/f026194db425743c7cd02d3ed50deb67	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	11	\N	\N	\N	{"query":{},"body":{"departName":"运营部","parentId":null,"departOrder":6,"description":"用户、内容、数据运营"}}	\N	admin	2026-11-25 18:30:10.25	\N	\N	5311779fd3df6724b5b9cb8c134d183d1283b86afc2fbe77d3a447be63389e06
4be4d142fa51a33d5c87e97f2120b161	0	0	\N	部门管理 - PUT /api/v1/depts/531503f12d9cdf729d9ce8ae535ca6ab	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	20	\N	\N	\N	{"query":{},"body":{"departName":"法务部","parentId":"2756c6363bd77819291b0e003c019dd1","departOrder":5,"description":"合同审核、合规、纠纷"}}	\N	admin	2026-11-25 18:30:10.256	\N	\N	165c934faa28d2ebc74e037abc19786864ca1e3b442a1f9d32ae5f9016e9c056
f4689d41cff3259fe63b07a4f5680006	0	0	\N	部门管理 - PUT /api/v1/depts/f026194db425743c7cd02d3ed50deb67	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	17	\N	\N	\N	{"query":{},"body":{"departName":"运营部","parentId":null,"departOrder":5,"description":"用户、内容、数据运营"}}	\N	admin	2026-11-25 18:30:11.736	\N	\N	a7bf01e4fc3f512e1ef2851b4596e39869ef3809f87118339865fb2917b1ebda
00bc9a61322e30056645d13e8037b765	0	0	\N	部门管理 - PUT /api/v1/depts/6cae4d898c1073b39b0b0ddd5364c928	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	19	\N	\N	\N	{"query":{},"body":{"departName":"销售部","parentId":null,"departOrder":4,"description":"签单、客户关系、回款"}}	\N	admin	2026-11-25 18:30:11.737	\N	\N	a53ebd25c7aebd2623834d1f0c177e6a5425ef547fa0c8d0061538cf8c022944
bf52cc49606922d52296fefc7f8b2784	0	0	\N	部门管理 - PUT /api/v1/depts/1577baeb20661e0ba522c60351c101b2	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	32	\N	\N	\N	{"query":{},"body":{"departName":"产品部","parentId":"2756c6363bd77819291b0e003c019dd1","departOrder":6,"description":"需求、原型、用户体验"}}	\N	admin	2026-11-25 18:30:11.747	\N	\N	c9c3547b0abd3cc3fc5be69b32837f086c0e98726d48a0f9984ef0301f3cd989
2d3d2eeacc1dfc138568ce1cce235234	0	0	\N	部门管理 - PUT /api/v1/depts/6cae4d898c1073b39b0b0ddd5364c928	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	11	\N	\N	\N	{"query":{},"body":{"departName":"销售部","parentId":null,"departOrder":3,"description":"签单、客户关系、回款"}}	\N	admin	2026-11-25 18:30:13.568	\N	\N	5641b3c2e61887b9d0ea0fa0b909d3b00b4c7daa8e95336bbf16af3e3a264e4c
d7dcf718cc499c020e4fb373edb0a4c4	0	0	\N	部门管理 - PUT /api/v1/depts/5db52b767a1cbd831537d81976df3a95	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	12	\N	\N	\N	{"query":{},"body":{"departName":"市场部","parentId":null,"departOrder":2,"description":"品牌、推广、获客"}}	\N	admin	2026-11-25 18:30:13.569	\N	\N	61438cf1617152fefa68652e2ada1e3daf4513c6f8e9d67022413740fe4d189e
9b185d7decbd09cdfccb385b9eaea141	0	0	\N	部门管理 - PUT /api/v1/depts/fd6753b0084a2074f64f6c3bab3ff032	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	11	\N	\N	\N	{"query":{},"body":{"departName":"客服部","parentId":null,"departOrder":5,"description":"售前咨询、售后支持"}}	\N	admin	2026-11-25 18:30:13.57	\N	\N	e81581537c67c585573a2213385afba03716e6bc1c7798cceae9cf152e586208
d339f9512cf4586fc37c603c3e1fd56a	0	0	\N	部门管理 - PUT /api/v1/depts/f026194db425743c7cd02d3ed50deb67	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	13	\N	\N	\N	{"query":{},"body":{"departName":"运营部","parentId":null,"departOrder":4,"description":"用户、内容、数据运营"}}	\N	admin	2026-11-25 18:30:13.572	\N	\N	88eb068bb478681ebd45bb76ff83c4fd4dd18cb80d7e3246400f4044fd1b2528
ea35c23b29c5ba8e0d45d85a26244d16	0	0	\N	部门管理 - PUT /api/v1/depts/d3e1489934c2d5d5cf10e4cd614c4404	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	19	\N	\N	\N	{"query":{},"body":{"departName":"技术部","parentId":"2756c6363bd77819291b0e003c019dd1","departOrder":7,"description":"研发、测试、运维"}}	\N	admin	2026-11-25 18:30:13.576	\N	\N	cc789b37dd36bdcaee115e3f72f55c4de35590d676e5447d5aa1aa99bf09a1ef
6123ee1dd0fe07c95462387e769501ae	0	0	\N	部门管理 - PUT /api/v1/depts/f026194db425743c7cd02d3ed50deb67	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	14	\N	\N	\N	{"query":{},"body":{"departName":"运营部","parentId":null,"departOrder":3,"description":"用户、内容、数据运营"}}	\N	admin	2026-11-25 18:30:15.495	\N	\N	0fc09437a8c7933124cd602efa41d3727855c88b6faf76431b882ff350dfe80b
dd1aabe1b5c2b8d0cca32adb96ed126a	0	0	\N	部门管理 - PUT /api/v1/depts/fd6753b0084a2074f64f6c3bab3ff032	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	15	\N	\N	\N	{"query":{},"body":{"departName":"客服部","parentId":null,"departOrder":4,"description":"售前咨询、售后支持"}}	\N	admin	2026-11-25 18:30:15.497	\N	\N	04a4e9b67480554685e3b9c6b3e378cb5fc06d4b2de630631a5ea07ce1c571a1
9f87fdf34bfe423afaaa71dbadc6881b	0	0	\N	部门管理 - PUT /api/v1/depts/6cae4d898c1073b39b0b0ddd5364c928	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	17	\N	\N	\N	{"query":{},"body":{"departName":"销售部","parentId":null,"departOrder":2,"description":"签单、客户关系、回款"}}	\N	admin	2026-11-25 18:30:15.498	\N	\N	3a617f61f5f26c7883ec1fbb2c9bd2bad0b92437af7bae6b726ad81f17cf2c37
c82aa9474b6735cde01535a29c51d2a2	0	0	\N	部门管理 - PUT /api/v1/depts/5db52b767a1cbd831537d81976df3a95	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	28	\N	\N	\N	{"query":{},"body":{"departName":"市场部","parentId":"2756c6363bd77819291b0e003c019dd1","departOrder":8,"description":"品牌、推广、获客"}}	\N	admin	2026-11-25 18:30:15.508	\N	\N	efe237017cd7b0f88e220d7b1468aa39e2a05b7c5615d32da842f0ab4c954689
352fa2c0b5fdb838ee563213b49831e0	0	0	\N	部门管理 - PUT /api/v1/depts/f026194db425743c7cd02d3ed50deb67	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{},"body":{"departName":"运营部","parentId":null,"departOrder":2,"description":"用户、内容、数据运营"}}	\N	admin	2026-11-25 18:30:17.201	\N	\N	3e3285d183db4f2b18a9842b78124d077604da9503ec94546fcb801cc8cfe98e
2319c97b421f1ef915f76b0a63cf1723	0	0	\N	部门管理 - PUT /api/v1/depts/fd6753b0084a2074f64f6c3bab3ff032	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	6	\N	\N	\N	{"query":{},"body":{"departName":"客服部","parentId":null,"departOrder":3,"description":"售前咨询、售后支持"}}	\N	admin	2026-11-25 18:30:17.201	\N	\N	2537b2a527e0f249dcd84c182ada2af39ec59858098901208f9a1d2e240ac2fe
3f00bd38ccad42db0a4f170ac33c1654	0	0	\N	部门管理 - PUT /api/v1/depts/6cae4d898c1073b39b0b0ddd5364c928	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	14	\N	\N	\N	{"query":{},"body":{"departName":"销售部","parentId":"2756c6363bd77819291b0e003c019dd1","departOrder":9,"description":"签单、客户关系、回款"}}	\N	admin	2026-11-25 18:30:17.207	\N	\N	afc0d2c6c890b8256e59b6ace1f400928874e398be4a3393950e23cafe4398a9
190eb21400beb37f0cdd239d856ce799	0	0	\N	部门管理 - PUT /api/v1/depts/fd6753b0084a2074f64f6c3bab3ff032	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	5	\N	\N	\N	{"query":{},"body":{"departName":"客服部","parentId":null,"departOrder":2,"description":"售前咨询、售后支持"}}	\N	admin	2026-11-25 18:30:19.258	\N	\N	43dcd15ee8f50e355a5bed1388442d5945b25dd16180600bb3f67bcf38f86a23
4218b169b1ed767a9a2589a76fc7ec76	0	0	\N	部门管理 - PUT /api/v1/depts/f026194db425743c7cd02d3ed50deb67	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	17	\N	\N	\N	{"query":{},"body":{"departName":"运营部","parentId":"2756c6363bd77819291b0e003c019dd1","departOrder":10,"description":"用户、内容、数据运营"}}	\N	admin	2026-11-25 18:30:19.269	\N	\N	883c792de9f7987fa1818bc2cfb614188f86242fc55e97c8fc34ba7d4ff5c263
a4a89a610081d083b57c2158a442b7af	0	0	\N	部门管理 - PUT /api/v1/depts/fd6753b0084a2074f64f6c3bab3ff032	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	13	\N	\N	\N	{"query":{},"body":{"departName":"客服部","parentId":"2756c6363bd77819291b0e003c019dd1","departOrder":11,"description":"售前咨询、售后支持"}}	\N	admin	2026-11-25 18:30:21.43	\N	\N	6e2463454350ae3709f1afe1e6c416b10c6edfc2cd807f3d7149aaf4c32276ef
b54394bfc1a74b920313c106781fc3f5	0	0	\N	部门管理 - PUT /api/v1/depts/2756c6363bd77819291b0e003c019dd1	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{},"body":{"departName":"ConciseAdmin科技1","parentId":null,"orgCode":"CAKJ","orgCategory":"1","departOrder":1,"status":"1","description":null}}	\N	admin	2026-11-25 18:30:29.393	\N	\N	88c824474f495f086dc2b0d17a1bd0d6b0a6879639cb30ac1dec8a2b2031cc02
e61ba8c0b8197125ddddf0559c3a7d97	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	12	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:30:24.016	\N	\N	5ebc157a3859a7fb5fb5f10bfe5187b358bb4533266cb7d6d2fa656484dfa547
e91cf1e16108eba9784578474a9efa92	0	0	\N	部门管理 - PUT /api/v1/depts/2756c6363bd77819291b0e003c019dd1	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{},"body":{"departName":"ConciseAdmin科技","parentId":null,"orgCode":"CAKJ","orgCategory":"1","departOrder":0,"status":"1","description":null}}	\N	admin	2026-11-25 18:30:41.302	\N	\N	33d130715a520d2c0cac5619a4b71443c3355c5a4405cb37298ced500df2c2cd
bda96a970bafe2dfc8b33f9ffc3282a5	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:31:24.286	\N	\N	55b8eb85bebb6ef5af1d7823e03ccce57fdd5d9c5b25492eeda7fe7e0663ce0d
b2d5c815af5f704eb51d8a665197dd8f	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	69	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:32:24.254	\N	\N	8fef7599ddab6f6a97bad9bc121e81f69256f6962ce6ccf1bb13911286652e2d
96d32a3f6bb6c6c0c9e7e7a3dca05d47	0	0	\N	部门管理 - PUT /api/v1/depts/af598343d6bd897baa306c5489790bc7	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	29	\N	\N	\N	{"query":{},"body":{"departName":"总经办","parentId":"2756c6363bd77819291b0e003c019dd1","orgCode":"GM","orgCategory":"2","departOrder":1,"status":"1","description":"决策辅助、文件流转、高层日程"}}	\N	admin	2026-11-25 18:33:17.361	\N	\N	9bea51198492abfd03f601336664f6dc6e4085b54b16cd72edc6dbdb0248b617
fa07c0bbbe47dcd6113c8d9f313986bd	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	12	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:33:24.01	\N	\N	2a75b91e381afd932b964743a2c154c5589f6c47ffcea1ca955728f497dc879f
68935ab47471e756564410d6d1a8e353	0	0	\N	部门管理 - PUT /api/v1/depts/064719832c25df4ba5f58bfbf8872284	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	13	\N	\N	\N	{"query":{},"body":{"departName":"人力资源部","parentId":"2756c6363bd77819291b0e003c019dd1","orgCode":"HR","orgCategory":"2","departOrder":2,"status":"1","description":"招聘、薪酬、绩效、培训"}}	\N	admin	2026-11-25 18:33:30.859	\N	\N	e35685ac6cba49adc9372e3a0f0c616a1b553ed1db9ed436eabee80554a6f8b3
e84886aeb4cc7f281376c1df06e10277	0	0	\N	部门管理 - PUT /api/v1/depts/2128fcf7ff6c60920e2294e2b009b5ab	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	12	\N	\N	\N	{"query":{},"body":{"departName":"行政部","parentId":"2756c6363bd77819291b0e003c019dd1","orgCode":"AMD","orgCategory":"2","departOrder":3,"status":"1","description":"前台、办公环境、资产、车辆、接待"}}	\N	admin	2026-11-25 18:33:42.762	\N	\N	dedf51f1542f22f4951ffe067bf335cf40418556741b14477f488d6d72048bae
b72f03e7523a943716f49d731a892c5b	0	0	\N	部门管理 - PUT /api/v1/depts/555f8f0307a3d92dfa3923b58889decb	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	32	\N	\N	\N	{"query":{},"body":{"departName":"财务部","parentId":"2756c6363bd77819291b0e003c019dd1","orgCode":"FIN","orgCategory":"2","departOrder":4,"status":"1","description":"会计核算、资金、报表、税务"}}	\N	admin	2026-11-25 18:34:00.852	\N	\N	afa86d2da2277f1b16611a7d992db7613f748c5097e1b5f00ffa228f9035a1fc
273841ff7015212f3e176f1b98533a6d	0	0	\N	部门管理 - PUT /api/v1/depts/531503f12d9cdf729d9ce8ae535ca6ab	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{},"body":{"departName":"法务部","parentId":"2756c6363bd77819291b0e003c019dd1","orgCode":"LEGAL","orgCategory":"2","departOrder":5,"status":"1","description":"合同审核、合规、纠纷"}}	\N	admin	2026-11-25 18:34:15.583	\N	\N	b8db1f6e0a003b41ce697830baf129242036b4080798718f7979f6a7f982e023
8e844054f354f270e402161427c21a7a	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:34:24.031	\N	\N	48ed19e2b05e5ee7121f89dec9cf5f52a47000f0ff4fadf16b258dd9b98559e2
2f19856c07ea0b15cb532a7cc4c7e38d	0	0	\N	部门管理 - PUT /api/v1/depts/1577baeb20661e0ba522c60351c101b2	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	13	\N	\N	\N	{"query":{},"body":{"departName":"产品部","parentId":"2756c6363bd77819291b0e003c019dd1","orgCode":"PROD","orgCategory":"2","departOrder":6,"status":"1","description":"需求、原型、用户体验"}}	\N	admin	2026-11-25 18:34:29.17	\N	\N	d4690da739eea45d67249f1144b54607dbe925abd60e508bcdb27bf3a21c7493
fd4e5c40e00a8425bc3c14952302b659	0	0	\N	部门管理 - PUT /api/v1/depts/d3e1489934c2d5d5cf10e4cd614c4404	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	17	\N	\N	\N	{"query":{},"body":{"departName":"技术部","parentId":"2756c6363bd77819291b0e003c019dd1","orgCode":"TECH","orgCategory":"2","departOrder":7,"status":"1","description":"研发、测试、运维"}}	\N	admin	2026-11-25 18:34:45.234	\N	\N	49301032a4cc0bed7fd83ed6a3487b31a01fdfe1b2d8a59546e270592ec1e9b9
9af2bcd00b2fb9e4ce8dd8399e9d5ec0	0	0	\N	部门管理 - PUT /api/v1/depts/5db52b767a1cbd831537d81976df3a95	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	12	\N	\N	\N	{"query":{},"body":{"departName":"市场部","parentId":"2756c6363bd77819291b0e003c019dd1","orgCode":"MKT","orgCategory":"2","departOrder":8,"status":"1","description":"品牌、推广、获客"}}	\N	admin	2026-11-25 18:35:01.471	\N	\N	e0fca7be1bbe3cc9e7667609107d2d20f212a0029ee3074642ffba509efb78b5
2a1118a9303c0d82cee0289c17fae528	0	0	\N	部门管理 - PUT /api/v1/depts/6cae4d898c1073b39b0b0ddd5364c928	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	33	\N	\N	\N	{"query":{},"body":{"departName":"销售部","parentId":"2756c6363bd77819291b0e003c019dd1","orgCode":"SALES","orgCategory":"2","departOrder":9,"status":"1","description":"签单、客户关系、回款"}}	\N	admin	2026-11-25 18:35:19.211	\N	\N	235f4d888ceb5adcb4d16d91960f8c7b045851258100fe6b3a1a24551197148c
5ca5e17a4cc642d718b8a6d69a608a55	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	5	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:35:24.085	\N	\N	636ebc2dd77e489a49a02ad1b19026995a9454ecedafd372b7ee587d508320e6
a497854a55e1eda05b14bdd4c624bb3e	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:52:30.295	\N	\N	54f7165371e41c5eba5c9b264aadd84273a3aeb920ba6dea8fb94ddb121cecbd
5a4663f9f8cea0fd1c73e009e863c215	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:56:30.749	\N	\N	caa4c7bc8f954cbb3b9a839580d8316146854b4684cba7ce325edb2d715ff6a5
855f5232aaad91796d96592d1d0d7afe	0	0	\N	部门管理 - PUT /api/v1/depts/f026194db425743c7cd02d3ed50deb67	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	20	\N	\N	\N	{"query":{},"body":{"departName":"运营部","parentId":"2756c6363bd77819291b0e003c019dd1","orgCode":"OPS","orgCategory":"2","departOrder":10,"status":"1","description":"用户、内容、数据运营"}}	\N	admin	2026-11-25 18:35:39.772	\N	\N	91c1f340d760a99b73a8387d60c53e04c7514bd97c02ab4dd57fdbd6bb895579
0444c282e98da03e028933266638dcc2	0	0	\N	部门管理 - PUT /api/v1/depts/fd6753b0084a2074f64f6c3bab3ff032	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	25	\N	\N	\N	{"query":{},"body":{"departName":"客服部","parentId":"2756c6363bd77819291b0e003c019dd1","orgCode":"CS","orgCategory":"2","departOrder":11,"status":"1","description":"售前咨询、售后支持"}}	\N	admin	2026-11-25 18:35:49.507	\N	\N	2a95b07a802e48d8b7c400e7b81677e8301e48a4cbc986d273f1f373262b4047
a52702860021e6c64f25a63b7e8a9f2d	0	0	\N	部门管理 - PUT /api/v1/depts/2756c6363bd77819291b0e003c019dd1	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{},"body":{"departName":"ConciseAdmin科技","parentId":null,"orgCode":"CAKJ","orgCategory":"1","departOrder":0,"status":"1","description":"总公司"}}	\N	admin	2026-11-25 18:36:04.142	\N	\N	1bd84313dc5d784c34162f2cde72e51a830aeb25d1a44d41c75cad35c9f808cb
180899b1a89e9a0c2db5a739e6d3d652	0	0	\N	部门管理 - PUT /api/v1/depts/2756c6363bd77819291b0e003c019dd1	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{},"body":{"departName":"CA科技","parentId":null,"orgCode":"CAKJ","orgCategory":"1","departOrder":0,"status":"1","description":"总公司"}}	\N	admin	2026-11-25 18:36:15.285	\N	\N	29302625b43b225996ab739cf50777c09071468cfa3e323eecb5c05e50dc323d
945edd935916d6328f53478c31190b86	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	18	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:36:24.014	\N	\N	73b1633bff48eb6075f4eb057501669cf6c412baf6caad349d36ac1daeff5358
a173e1c7cf3f35fff71ca5d31895550b	0	0	\N	部门管理 - PUT /api/v1/depts/2756c6363bd77819291b0e003c019dd1	1	3	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{},"body":{"departName":"CAd科技","parentId":null,"orgCode":"CAKJ","orgCategory":"1","departOrder":0,"status":"1","description":"总公司"}}	\N	admin	2026-11-25 18:36:39.991	\N	\N	0ef4945bd8549b9d30100ee5a33d20f7644a1313abe07332c3c8570cd6d35519
a68cd7672838decca4f2501e50f3b356	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:37:24.296	\N	\N	05dfdf456e5e14a0e473d77dee80dcc71f0a2f515910aa333193680ca16b9840
e2860a9f33b7f6fc6a29799f0d7e0fb5	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:38:24.286	\N	\N	6f449d2c035c477ec77579f939006d8a4fe13a207ffc101693fe0f97f866867f
df4cd174cfe84c849bff09c4b818e927	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:39:24.295	\N	\N	793af2c0d3786391753be1a3f97e84eb416b262052e7484c3998d44050eb599d
cfdba4a0b2ce2564bbcf4f55325a9b0c	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:40:24.301	\N	\N	42a28994a1602eafce0d65179f7acec716e4716fc9da8230eacb6a5a453b9f92
bbcefe3dde8d1e623de4e8acae537be4	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:41:24.298	\N	\N	456699147fba9b7c9db3151befa537c8cdd07311c3d05674f3dc5ea7b41dee69
4460378c66a79375a2c238131d2ffab4	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:42:34.3	\N	\N	4f8732fd99f99df22e41d900796fb64394e644190e7b8d51281ca1e79673bf66
2e99b1b629e01aac33148f17d30fb7fd	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:46:24.31	\N	\N	282abf23de157ea97a6a61d889a1d9f8239f92486236f0ea398129c197a21a08
452e74515d1db35b2bd5699f9f24aa6d	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:47:25.274	\N	\N	5b1c10caf049d44480a0731362a65c508e2ffe1c10491b19eba3662657376b7b
9123ac6fc1518a6d9a87135e5776ea54	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:48:26.282	\N	\N	bcf10d48e8da130f21432ff797dde5d5fd6e91b78cd2a872f63673b5adb1526d
c2b9bba77fe73962a7e7021c81c24d20	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:49:27.296	\N	\N	0e42e9cfb99eab08ffb20ea2d481292df03860ca1cf0d251bf90920395d78e7f
adc960a8713e575e4ddd8c718f989ea7	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	15	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:50:28.301	\N	\N	9f7f2d06925e621d95391735aca09cbb76a0997f0405d299ce0826efc39bfde6
802081f7f819d234e7c77c4bf1b3f019	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:57:31.293	\N	\N	766563bf33a50f0d9888cf1ebe66638642344fad5696c17e841072806838cce8
a54866876e9e71c576cd60585278c70f	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	11	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:58:31.318	\N	\N	5858d54e7475fc030f22057bb579c53f34df900d62cdb367c12cc06f83b91951
d30601407bd87e36a5c98775fc6b5b66	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 18:59:31.301	\N	\N	2c14ad0554dc0fd9b58de62989de0dc345a797cc9020b3f51fda1237eb36afb2
db28f9c5c9b57482d9590f4eb3742b5b	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:00:31.288	\N	\N	6b50f1f2d2bae49bcf734d4d6fd110d039eef61e1a16bb20fb23c7314ae56500
9c7f8d92aa619d505d7a38c286c8751c	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:01:32.288	\N	\N	4c7fa014cf3a76f7d53d3fdf301ba9383f101bf2ccda080f9742f2ba71df9beb
23fc7cc94d2824afa004655a15d7e353	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	11	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:02:33.327	\N	\N	24c38c3a00bc7d48fadad0868b41c804b90a2fc508ae441ac9c0ab3249813b05
475a893e6c967664f306cd07ca2554d3	1	0	\N	用户名或密码错误，还可尝试 4 次（连续错误 5 次将锁定 1 天）	0	\N	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	1	\N	未知浏览器	未知系统	本机	\N	\N	admin	2026-11-25 19:03:30.834	\N	\N	169f4b867def619acec9e9f54b1223902b229176218652c3a01a652a2a381a57
1a8d2fd65c2709b9543c7c0d5ab4a190	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:03:34.327	\N	\N	a322983f39d8e5ed3a94748bdc1bba394bb4d847c796264474acaee6c11ba81f
541354b5a62746b3710a79e9aa2f81fc	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:04:34.323	\N	\N	e5a3dbf644c4f776250be4c6fdf463acbe555ac4470742e67a6e39b97824c1f0
ce900967db8a5e759f52e385572ca1ff	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:05:34.353	\N	\N	bfadb1e92959a9d436d69d76c8728db6ab87ba09e2b15bdbdc13b3365fea3435
39cfcb2c747016c076d551992f329118	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:06:31.293	\N	\N	b6bf284681488198a1db594b00223d7a085b663353081cf7b90becb7a4e8a5a1
63a28cd1497de44f973f0dcb4ed6c7d5	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:07:34.288	\N	\N	56b89b2e53ab15980879fdc54a24d6369dcac30cfc037756c6359b3257ad3c6d
00d46a31bb069de6ef777078afd841c5	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:08:34.306	\N	\N	1a5b58d142347f9f1ed1e7b26666dc3dfccdf5afca69ef7d9f49b2660fa1388a
78cb22721e093eeedc867a86e396a1a5	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:09:34.292	\N	\N	b5814786a85bb222e7122c3506dc5dc6958a87047227c9fcb47a16db651fe9b2
26743a2213469a8af0a5cd75e4fbb01e	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:10:31.292	\N	\N	3274923ced96bd82f72ef68fddbd6dd64a1a2422f20e7fd6972102377cfbc595
a8e1e8375a27833b0ba5bb5a0088225d	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:11:31.177	\N	\N	45b2dae6ac8809e465f0f380295f0edd5ad265e318c2c46f23afcd6830d37808
2e73b56ed9d1431cb70a7a6ccfb659be	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:12:34.303	\N	\N	a2e3e7c572137065fe79ee7f68e7eba7b47a021d8f8fe8252b5f37dacd71a4a8
a3edddeee57bb41429b2683d4882c1bb	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:13:34.298	\N	\N	06da1b3cbade3b75ef8c3021522c13a7e8128c5ce48724d7c1cc5d9f44f65123
3ed8a3a016c5cf57e933bf96e2d96f8c	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:14:34.306	\N	\N	733265319be8c4bab7741354b76854fadacd9f859ed289c5c6fe3ae0b8ef3cfc
b9f578682f4cb332085b6c5a01900754	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	22	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:16:13.378	\N	\N	124b0506ea802590008252c7a4d9ae0fca1ff3fd7e636318e474796dc9bb5e34
298b0bccf3616e5c92482abefe86f329	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	3	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:16:13.436	\N	\N	24c4a63721d66a472df159d8c9c28ac7b88ac97fc57eb356d273f8e86f959f09
6635e555a180dc80fd4e6f6a99c43605	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:18:05.925	\N	\N	0f4621abc35e60135a61972562535508a8b4e266730bca6d2c3b54437517ff05
b6845a15a620f3f84c41df807c3808d0	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	11	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:19:06.343	\N	\N	98da4de8eb726e1cd60c87ffb31e67ed138ae7fbe5eb04102149779eda19f6a3
de44190419866a804b19e38e41e2a973	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:20:06.296	\N	\N	8dbac40b3e8efc1760986720c979cb42eb8eb9dd57952ea09cc4438309f9484d
1c2cf3292e893a4d78c00458cddb250b	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	13	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:25:25.337	\N	\N	3d263644602183a399f0134480832515fbb730181045c8a28154dc012266c0e3
db9b25d36952ab4cd359818f062d53d1	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	121	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:25:39.737	\N	\N	a26b2706440dbd13814a6837ce8fd521f4df315dd069b10e5816b77700884060
b984bbf87c98fd0c40149059ac59aafc	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	2	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:25:39.777	\N	\N	d8ff89584e798454b14a109f8875fafe6706b73507282ec55b3279dc1631263c
b0ffa91ab701006154bc278157726da9	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	13	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:26:13.8	\N	\N	b24f4ac2c8d186fb3089606f284a6acfc742599f4f354cbfd0584bc105bbe694
be484d4cf80074cfb9d5fae6bd493246	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	3	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:26:13.843	\N	\N	263cbcf90467b436ec1395053fac3b7f53ae23c3c8bd6b95b055e871ad341927
c18e6113f48ca132537e3ee4b427d13f	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	116	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:26:25.226	\N	\N	3ddc695e82dddec2868c8bbe84b1269f36a2e37eb592de7ca0d50093e675a844
9d2d77c1fd931987107e179a33708964	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	5	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:26:25.265	\N	\N	3a4a91c54fc474a309e6269e3a46221769c638b57cbd264cef0541fa71139fde
4be871d207ea834f4802a55343200c85	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:27:25.364	\N	\N	22ef35188151c558201d244a23c471bf55c72061bc81b9aee5733559084b47cd
6837e3dfd5bf201d149c5842005791da	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:28:25.293	\N	\N	bc7cb5dacd3e0221491d7588d6650732f78964e4cad7bca5da2ed389f89a7bfa
7193409f7e213dbce57cd17454ecece8	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:29:25.307	\N	\N	7a2670e2bf75a4406def437d2d5b7dc34be61cb40069fadf4f90c5596a2085e8
40cfc24ac249936d687e0faa0510d060	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 19:30:25.28	\N	\N	a784fa44947b0645dcf6f27585a8591f7fb62f99a8e96da0486afdf1ed960b05
277df03bbd6e3f172af3d308e42b144c	1	0	\N	登录成功	0	\N	0c8c4eeb19abc6c501b59287ba5ae9e4	xiaowang	127.0.0.1	0	\N	Chrome 158	Windows 10	本机	\N	\N	xiaowang	2026-11-26 01:46:37.622	\N	\N	ea92f39652aedeb7fe2bf0c051c93dc82d5a6a8a842d5a3cb5b8490edf9ed4ef
7990021da6add6c8f1d917004141872c	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	16	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:58:17.887	\N	\N	6831c365d299b7734ce092845b4044ce97c5112c01928de75b942e23a2d97ceb
fc0c37bd0d6cc3a7353d22d2ba67d3ce	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	14	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:17:08.924	\N	\N	94977c0f5b571dde444da1f33b7beab4789456b166c8c84831402fa10bb49f44
9dcc0ea99bbd02fd6ecfc76355e6804b	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	26	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:34:06.737	\N	\N	700aad62eb6bbdcfbb67ea2849eb859d1cebdabe253890b8845c275cb336bf05
41e981c73c698af560083aed7a29c877	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	35	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:43:57.461	\N	\N	8ddfa8af7827d22dc434bfee1b99acd85710784a7645795e34fe6a1de13c40c9
44f27a4cee2ea2c0a4780cabf3771bc8	1	0	\N	登录成功	0	\N	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	\N	Edge 158	Windows 10	本机	\N	\N	admin	2026-11-25 22:25:53.756	\N	\N	c752bbefc5710e2d6c2a8b4baa187d53d091f22f01e16a9abe053c56f3f0ae1b
408edb4143fc069457338fde25e89969	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	18	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 22:25:54.723	\N	\N	ba1d2d8eebcf1972d5860876664285e581834e284d566d6b3842a357c793c9c0
b2ba0e0ba75aa8266194155205d0e9a4	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	23	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:02:30.904	\N	\N	93abca63e90c70581468ed1fe1018607abd6cd99b7d383fd5d8f0b082dcecb79
5f31044e10f60d79d1df5b1e7bdde2f3	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	21	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:13:08.966	\N	\N	87d4bc94e18bd65ed16edc83d7371d557efe599fa9ba291d155640363f5c5499
82b51cc281b340c36ff819a6397f1f07	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	19	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:29:22.086	\N	\N	f5667437fd199ce9f57b274079b4cc3e344a21dfec2a7946b285761c4e08cff1
93c517dca23eb2bcc7ec12a26a68138c	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	26	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:44:48.976	\N	\N	8433810e8ece82dd7c709d351abd8ff162eae61ab6993071c699ca64e66d197b
f595a4611f1b7dd1d0c0ab0140bc0aa3	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	21	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:03:08.991	\N	\N	f3c8c4dbcaf8ee3f00c22ce26fd492a58c916859f74bdce83579ff497bb8c69e
1199eee998ded25b35e616e9f3c3ff2d	1	0	\N	密码错误次数过多，账号已锁定 1 天，到期自动解冻，或联系管理员提前解锁	0	\N	0c8c4eeb19abc6c501b59287ba5ae9e4	xiaowang	127.0.0.1	1	\N	Edge 158	Windows 10	本机	\N	\N	xiaowang	2026-11-26 01:15:18.697	\N	\N	56a2fa84a7bb12a33487ebb114c1ea6ad185c3cddf6f6d0fabaf8fd2ff237b08
df7917fb232bc67bcd4ac62b4ad7f06d	1	0	\N	登录成功	0	\N	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	\N	Edge 158	Windows 10	本机	\N	\N	admin	2026-11-26 01:32:48.307	\N	\N	051e90f5f768b4b80bfebe02fc28d5fe240b499fd08f6b3bfe774c32718c5193
ed099527c8ca62912925ce4441c0f6a8	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	25	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:32:48.729	\N	\N	881b31b7d5a00cea4cffab1bd526d24689ea016bab575a6eafa8b23d77dbbb34
a56df155eee32d4e37425ca1f563a515	1	0	\N	登录成功	0	\N	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	\N	Chrome 158	Windows 10	本机	\N	\N	admin	2026-11-26 01:42:49.201	\N	\N	122edb1dd7260d0a3f8313b1f9753253b6e3c52a29ca6d40bc0a09dda8ecb34e
a45b6c23b4c9aa29ea201614d0563738	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	17	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:42:49.972	\N	\N	161f662dde0b883cebaea4fa4db23d153676cee598b4626773abdd74fca9df4d
f4cfff9502fe5f207e80fea0c300dfb4	1	0	\N	登录成功	0	\N	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	\N	Chrome 158	Windows 10	本机	\N	\N	admin	2026-11-26 01:47:05.421	\N	\N	e4d9e7e88f987fe37b75d46e7b54c22a5d8ee5b2f3818839fa53b323130c63fc
1a82910c78d511cdb4a0ccde5e49f88b	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	31	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:47:05.972	\N	\N	18e023a4b4ad4e6439a197048c33d7caa24ff0ce25c1e5a1309e75a3103bd0a2
503f709d533a0e85499dddfb95b13c1f	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:47:06.255	\N	\N	20621d5aadae3bb34f68320077da8aa37f4900488cc5a45e390bece0e696e623
abf8e4e7f33baa55b833e7ac35c01904	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	13	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:59:17.897	\N	\N	8bd5f8e23f026e0cd5d8075299933fcf21fba479baa9fce4c501832d0c32b0c2
f0e67e2ee6f335cf885c2925ec59c457	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	17	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:18:09.01	\N	\N	20629cfaa647d634c66271303deb84ec7517479d405045398a89d26efd18080f
741a91b0cce271c89408e609bac92588	1	0	\N	登录成功	0	\N	devtest01user0000000000000000a1	devtest01	127.0.0.1	0	\N	未知浏览器	未知系统	本机	\N	\N	devtest01	2026-11-26 02:34:20.519	\N	\N	7bc3fba46351fda6620a5d4d198d0041a026021ccbae1fefb155fc9bd06aa61a
2f3db2b21d28e5c363831c27551eba17	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	15	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:43:57.719	\N	\N	2c58e8a5ada278910e2ddce54afe15d6eb8f793e40e12beaf065ae0e8568a251
631f81f3640d65471db2a423589b9b2a	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	456	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 22:25:55.414	\N	\N	5ea748b98e4726f91d9867c219d45501483b9f3ed50ec48ae06ba81bde3e66a9
4f56e6f9027e2764be56696efb8c1a31	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	16	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:03:30.906	\N	\N	555a6d8413188fabe7c1903e7465df4394f8653e48dd5bf32a067058fc640f0a
def891c4bbc46b679a57395d5473f6b5	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	38	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:13:19.62	\N	\N	2d76771869199d1c8657f2aeca5509db67e80db70a472528422185de001be78a
5f4aeae838c33429933e762d1f40a117	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	51	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:30:09.332	\N	\N	2e17780507b48ff20f5f104fa4eea214aef11cdf1538756a45bc3fee87157b37
54dc39bc081e66c5ed06ffdb32dd43c9	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	18	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:45:21.666	\N	\N	0ef49f46136877eafbb1991464199a620cec8f0ad921f0cd5644d9882600ecec
66df0f9195cf8a9e77daa4962c52be1d	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	179	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:03:24.548	\N	\N	3fbfb6c9a8ea2b10ba5f70a22459ed1b8de1df54cccf33e841bd9cacb66a6a19
553aa2bdf45a0df00ecc0a859a8b5148	1	0	\N	登录成功	0	\N	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	\N	Edge 158	Windows 10	本机	\N	\N	admin	2026-11-26 01:15:59.966	\N	\N	8fb91de5252aabe30699814b3993f1b76f7b7ed57ae6b5e51c84cc27cdfaf018
ad7657598ff204342c78915602c5a7ec	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	31	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:16:00.435	\N	\N	a1b27b7e44c6cfc292dfff669909db9dcece2afafc5e202c4d594c5bd14aad59
941225d791fe00663012462fb627b02d	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:16:00.596	\N	\N	6ff62b87ed34708cc8074a7b53334dfc71c703ce7995d11dd36d028734415664
afcdc87043e8223aa88ebef54a15d54b	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	77	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:32:49.257	\N	\N	e1fc9868d914223ddbff9d5b2b926421f37c846a36819be5b277ee4703f3bcf5
af34bcd640c78318992047cd138ab6a6	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	544	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:42:50.73	\N	\N	a9e21c840267451bd619a20b9b4782751542a9133c2478ae108dd4ab507c6b29
1d5c21ac9607d92e9fba93c8f0839861	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	29	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:50:06.527	\N	\N	5fcb8eaf7c7d95576a7c0fe303087969f685bbf9b925bf2d2b53d661b28f9861
80933ae2006a4a9b49f0c5d1b7871480	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	15	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:00:17.109	\N	\N	29c0009cc3e7137b57ef9273f60f96270917ad061cc97054a97a885aab63f579
f132c0f4f23b2509516e86e7a2a02989	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	18	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:19:08.96	\N	\N	b66e9475feca9b0a0abfd993addb7e778cd8e6fcb87a36572899a2c0066467f8
a797f0d2b675af8be0f50481f45acc5a	0	0	\N	岗位管理 - PUT /api/v1/posts/3e7ff770b6df3276a36d04bd5e60ae06/roles	1	3	devtest01user0000000000000000a1	devtest01	127.0.0.1	0	22	\N	\N	\N	{"query":{},"body":{"roleIds":["4d4c8d42c168e1ce94b7d2b3c76422b1"]}}	\N	devtest01	2026-11-26 02:34:29.023	\N	\N	9fa993bc6c11387ab62b545f3623b1e0ea423df23701aa0b79a38b7ab5789bb2
4fabe6ed6f201ff984ecae6e76f2347f	0	0	\N	岗位管理 - PUT /api/v1/posts/3e7ff770b6df3276a36d04bd5e60ae06/roles	1	3	devtest01user0000000000000000a1	devtest01	127.0.0.1	1	9	\N	\N	\N	{"query":{},"body":{"roleIds":["nonexistent_role_id"]}}	角色不存在：nonexistent_role_id	devtest01	2026-11-26 02:34:29.216	\N	\N	2668835e4ebc50c6156bb21c7584455e11f3d7e4dd9b6b4d20f1d46c27c354ac
8c2fbdf34c4809aede61eb8204819f47	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	440	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:44:34.675	\N	\N	2df5d72c11dbd4b8b00c2b72dd3a99d50eaf23d267afeb8b240ee27293e8f4f1
76cb2fd1fc6b6e452dc6f40f792cd1e1	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	22	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:44:34.998	\N	\N	5ff6c4b63586038a9e0376bd3e7db0ef2a44400e17f4bcdc3c02f253278259e8
907ae461b4a6e719f6bf22f5e363f872	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	23	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 22:26:55.933	\N	\N	66e5948e067e97be8d436148f16bd1cc07c1edf9dd5b2b1273d2b82015296910
58a68f188f20da93fe63e1af1dd5ce0f	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	25	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:04:30.898	\N	\N	68e076876582c6d0c12a44c296e2839de232b8796ddb39edaff2aae9f970db1b
8d14aac450f557d65054f397460ae396	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	21	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:14:08.963	\N	\N	3b6c90462cb1711e8a5afb117c6611d3a41eb2e953b7b7bada089806765c36c8
feab2958263d15b39311dcbdcfc33cf3	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	94	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:30:21.89	\N	\N	c2d893905e8604b3a3a0ba48008a33c964687d9d9cc96691d24e84425885797a
2ef880403eb4415f2b9fb16ff086bb60	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	13	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:46:21.91	\N	\N	f69697a0d4b630928adaa401f8c15569bb7ca2c7e32ece659f441dbb3d944fc0
b7135114cd069e3afa7a3bb4a9aca674	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	54	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:04:22.232	\N	\N	9a086669d2034a14591f950936a96f58c45ad51ae3c79edb303b251521cb988a
6fc47e648e282de9510da85a4d09693f	0	0	\N	用户管理 - DELETE /api/v1/users/0c8c4eeb19abc6c501b59287ba5ae9e4/permission-cache	1	4	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:16:13.361	\N	\N	d270a95a96691c85a4b28dd2038101c198ca63112db3da062c558e9abee6b9cd
15c84ca4438da0da7bc776d176d62cee	1	0	\N	登录成功	0	\N	41c5e48c0d6d1081bf9f4887f6d47606	fin01	127.0.0.1	0	\N	未知浏览器	未知系统	本机	\N	\N	fin01	2026-11-26 01:33:06.904	\N	\N	33f68b386e09790d555b51384fda546b348416d7ae755c2bfb1a548d36572018
3ee6dcefd80f6a1e37c0c80c4585c173	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	14	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:43:50.14	\N	\N	b5840ba3a43c1908574371ae524d79015f2c34a7752daf85d662ed408e407af8
0b7c9912279c7c12ad11c473578f913d	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	144	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:50:27.651	\N	\N	57bbf8e8e38d553ed93036792bc9729b8db4ff26a43dd6ec03529ce1b7443d30
5f87c3d70a78373ca7ce4ee113e42b26	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	13	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:50:27.841	\N	\N	546ec7c44326eb300efc732fc79803fc439acd287c541148e305d67b179a8d57
5b2f7c49665bc51a166c36f36f7503a4	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/tasks	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	13	\N	\N	\N	{"query":{"page":"1","pageSize":"10"}}	\N	admin	2026-11-26 02:00:28.187	\N	\N	b8755351e17702e3273df72f1c8fdc34b11c7b229998fb3d536d2100f1e23a64
de4d92dce1548dd4ce658d60aafb4d05	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/tasks	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	2	\N	\N	\N	{"query":{"page":"1","pageSize":"10"}}	\N	admin	2026-11-26 02:00:28.234	\N	\N	6a2e950294d14a2aec8b24bdcbebaa8a9663815823ab1da2170a663d9351e9aa
4d37a55c93b6b04dc148562da4daeaba	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/biz_orders	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{"page":"1","pageSize":"10"}}	\N	admin	2026-11-26 02:00:28.739	\N	\N	949a887c57819cc97990b708ab65697018039eb1fd9e82f1f2740d9ecdba2709
7f33f9fa5ea765a88a9921648c1e2ebe	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/biz_orders	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	2	\N	\N	\N	{"query":{"page":"1","pageSize":"10"}}	\N	admin	2026-11-26 02:00:28.772	\N	\N	ac36c392b6d762ebae8b23871c9813a806e0f969455f4d49fa825240e61f6ccc
78973cfe2cf9b557cdcd9658b22b6b54	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/customers	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{"page":"1","pageSize":"10"}}	\N	admin	2026-11-26 02:00:29.226	\N	\N	6a9db44c9a9544fbe3fe3f472cf3d52cc109ac24ef61525de43983eee4f5aab2
ed60929671451e1718972b2701e15d86	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/customers	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	2	\N	\N	\N	{"query":{"page":"1","pageSize":"10"}}	\N	admin	2026-11-26 02:00:29.261	\N	\N	7606f664ec2caa187cf2177408bd4cba5311e1c4f46939e288aaedd31fc7c5c7
d065a5c056dbe34e61cfec8c881d3ca1	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/suppliers	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{"page":"1","pageSize":"20"}}	\N	admin	2026-11-26 02:00:29.785	\N	\N	fff323269f6713bfb72d12ce7dc5e7f593366dee53c824c70f4518c556a3cb75
6acae28a741b224163d780b3086df890	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/suppliers	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	2	\N	\N	\N	{"query":{"page":"1","pageSize":"20"}}	\N	admin	2026-11-26 02:00:29.823	\N	\N	a7d8c3ea1b3e65d65f7aee69d73600e13704695b75e7d80cb294d056b4a57081
a89ec1970dc87cff3b3aabf8151a3c24	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	20	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:20:08.985	\N	\N	d334d145805e57a22a7cb32b5b60d0bbfacec9ce485d580945e6186b9fa0715f
32c3304ca81d5f32cf45b4740224d8fd	0	0	\N	用户管理 - POST /api/v1/users	1	2	devtest01user0000000000000000a1	devtest01	127.0.0.1	0	166	\N	\N	\N	{"query":{},"body":{"username":"posttest01","realname":"岗位模板测试","password":"***","status":1,"roleIds":["6dbea13a8673eb60c17a59c8381bf368"],"postIds":["3e7ff770b6df3276a36d04bd5e60ae06"]}}	\N	devtest01	2026-11-26 02:34:43.12	\N	\N	df9f6f46e4e1c54be0d3986a8a3cac9615304ff35e22d3dfb15fda8d47cf24b4
cf723117c0b1fd60d9f2e75a7e697af7	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	40	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:45:38.774	\N	\N	e4627b4cf18234f817452277875fa63616bdbb7a7b259a00376d553ed2439f5f
73cc447211218f863e9f09195cf72c83	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	19	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 22:27:55.922	\N	\N	7b1fbad21aa87c4cb819eead276071b6df80a5d2d284ae81128cdefddf1ec4c7
02eccae953ebe2a734b50eae3c294fab	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	22	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:06:08.954	\N	\N	611a7323eeb939cf2542fbf9ed466d86e4f79d6b4bca1251e88f3fb3e1b33420
b1d85cbf044399791cf57be75087cc3c	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	38	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:14:19.81	\N	\N	6cd5b7bbb54b92924eb86d150c02fde938890ce64c5e7910d0af1858512ab179
5408c3bec84ab07293eb01ccbff00641	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	20	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:31:19.943	\N	\N	4d4d39934612de0f46628da8354e01873ee6ee762cfbd1bf95c885a7a0b50d96
d7409bcb7a88754a3cfd972cbf366c68	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	27	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:48:09.085	\N	\N	b6cc58f84c4db5befe6c01350f4ff044d39589eb16d139cc2894d137952d8cc8
461e12bb67bbe3baf363d4bdfde76aae	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	47	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:05:44.444	\N	\N	ed071100d82900f513d47ffca1267ffbcf5781a5bf191cab573f6aecc2a10554
b224b19488fe23c309869ceacab4b837	1	0	\N	密码错误次数过多，账号已锁定，请 1 天后再试，或联系管理员提前解锁	0	\N	\N	xiaowang	127.0.0.1	1	\N	Edge 158	Windows 10	本机	\N	\N	xiaowang	2026-11-26 01:16:27.507	\N	\N	576ba5dc757f67c46b300a61c5f2559e959b91534f3528d3d066fec1c4f6b4ab
edf070febe32cf35f8740045f9460ffe	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	19	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:33:48.762	\N	\N	5d371a93be9142ad2f5d613ba047f56c2548e37804e2c07ee0a6f2efefee0688
70a9b92e6808f6cd6fb98eda2ba45702	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	18	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:44:50.927	\N	\N	81b6ff804a33c14d59c7cb0b8ee3c2c460487fa5ade7f8a0bb3a99f0108b7792
5a8451382bd2f41c086479e13c3117dd	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	24	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:51:27.968	\N	\N	fc962f2f3d997eafebb4267ed93250351d4a89839632275cfbca054884e43a92
d0ff83dde51c92eeb064e9ddb1b7f58d	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	13	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:01:17.893	\N	\N	29673d3a9250dd45cc5ad207978fa268dcaccf1ddc18377cf39d8a46e1ccdccc
b361211865d0289a55abe8ff145f33ea	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	23	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:21:08.95	\N	\N	7305318f989d0f87eb83e8c9e8bd5042441426e90c7fcfd1aae79090d79b719c
ed4d1b8a552fb98df739697641fa9245	0	0	\N	用户管理 - PUT /api/v1/users/197609/roles	1	3	devtest01user0000000000000000a1	devtest01	127.0.0.1	1	9	\N	\N	\N	{"query":{},"body":{"roleIds":[]}}	用户不存在	devtest01	2026-11-26 02:34:54.568	\N	\N	4243f262da80b6c8c935059f4846d21c8663f934e3e5378f44ce541341f10a9b
9c9186151d38d098f073a19dc6a60ed6	0	0	\N	用户管理 - PUT /api/v1/users/197609/roles	1	3	devtest01user0000000000000000a1	devtest01	127.0.0.1	1	5	\N	\N	\N	{"query":{},"body":{"roleIds":["4d4c8d42c168e1ce94b7d2b3c76422b1"]}}	用户不存在	devtest01	2026-11-26 02:34:55.672	\N	\N	99760db8b0d85e258e01bb480cf368771ca7b68f4b6118c8d851dbb7801b8217
a96d7866ac98a90ac5ea1ee0ddd1b22c	0	0	\N	用户管理 - PUT /api/v1/users/197609	1	3	devtest01user0000000000000000a1	devtest01	127.0.0.1	1	7	\N	\N	\N	{"query":{},"body":{"postIds":[]}}	用户不存在	devtest01	2026-11-26 02:34:56.591	\N	\N	44a1c756fdd9c463b7b3fb48fef58e79cf12ca1bc940a9abf876ed6e2bf577f5
3e4cfd363404825c684e5a8e6be9318a	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:45:38.991	\N	\N	240295109b36317145ece437ae6c59c510877b352cac17081f8c3f22f41008aa
1dbefb87b8bb3817e29e87506397c0bd	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	559	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 22:29:01.505	\N	\N	022c7ee27ebe84c059fc82472bf031c02a609da2d03f78e412bf90b390004609
2e485a6f6d0e68da4c8776db07e4bac7	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	156	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:07:09.677	\N	\N	45cc7a175a754cd293ecbd6b388dfcc35c63e76f74343d7a6cff8fe38239fd70
0f4d2fc5000b4e39d8dfbad2423a04a6	1	0	\N	登录成功	0	\N	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	\N	Chrome 158	Windows 10	本机	\N	\N	admin	2026-11-26 00:07:18.952	\N	\N	3c30dbe35b96e34c5b267e1a39ba90ac05756dfb8c7dc9a9aa88bba5f069a89e
62acd0aef301770b44f0f4b160e64255	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	28	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:16:09.011	\N	\N	6edb05a6a00937af0923b829c678d4ed8e00065ed095cce74f75f152edde1a0a
5b9f0dd7ff0e7642a3307e375af566df	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:31:21.797	\N	\N	1a0059e29c9cbd7eea6080cc46c0c38cb38484198b3ce255845dc2e0a84f84ff
eb17a24c5f157cedecf99a827acb8091	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	13	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:49:08.917	\N	\N	e8aa4d1cad595a2dcdb268953ce5ccff131d59960cee6fcf93b7e31885d8b9eb
41b0003f2e596959a7f2b0fa65bf3642	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	44	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:05:46.593	\N	\N	e4b7981c26657030739eecd7da635954b479b7e8b53043d4e0ad2c42ebc71258
fececa52a6410c9c7b6b7f270753f061	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	15	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:05:47.08	\N	\N	2291970d509b7d566055044719fc8e6df8631bc44e6dd2c6a58280cafe42c758
86f093e6e0df59bc91df65bce0509101	1	0	\N	登录成功	0	\N	0c8c4eeb19abc6c501b59287ba5ae9e4	xiaowang	127.0.0.1	0	\N	Edge 158	Windows 10	本机	\N	\N	xiaowang	2026-11-26 01:18:54.985	\N	\N	a683a0ca291da0c0e6cd59108422e1f2ee6c2380b7eaa680e15ebd6bb85b339b
9dc018875d8d9991dbfc655ab0512c94	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	15	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:34:48.917	\N	\N	85e147eb454573434dc6fec44a00521261a617c9f22578498d80b6809282f171
e509cf2d4dcde8d2f649e88dc884107f	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	110	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:45:49.968	\N	\N	39f19882edee3c6e403d84a0cabf3e4105dd48c09c9bd230be68c8e8a9acb9be
3b6b5c4f5a7f1681e3c507df27cfaa7f	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	15	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:45:50.668	\N	\N	ecb35708f6808524a1620cd016782db85f2e7860c59419433fd9bd0ba24133e7
935072825996f87036e8ee4fa324ca13	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/biz_orders	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	21	\N	\N	\N	{"query":{"page":"1","pageSize":"10"}}	\N	admin	2026-11-26 01:51:59.211	\N	\N	298cb579bf4bc347748e9a83de13cba7109f7dcd4a586c3e6312c3d4749c2197
1fafc24994cfda4a6c675d19ca48a8a3	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/biz_orders	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	3	\N	\N	\N	{"query":{"page":"1","pageSize":"10"}}	\N	admin	2026-11-26 01:51:59.258	\N	\N	b38f52bf01724bb2266d90f7671a886fd55bf03256f353fc40471416896fa8ae
ba1924befdf3e6ecd0601d917595447f	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	14	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:02:17.907	\N	\N	4bd5c3d0ef56a2a489b7ca620bda9711a7bf10bbfa70219c366472928ab7dc53
56bf669d5730699114a6bb1563b7aee1	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	41	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:22:09.162	\N	\N	e734ef405ac4f2fbaa1135d3c35af49bef5d03c0760b0f357bd4279d7abe9bbf
32bfe107adde2a5f80e803bf501e71a7	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	91	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:35:06.894	\N	\N	5cf8cd3a4d19fa38787fd0b76daeb88172fd865c40036b51b40a5fd55366ea0a
6d9ac6197e3a299f1d692405f999b0b6	0	0	\N	用户管理 - PUT /api/v1/users/f4d3e7a811e7d42ddf12e18045075c6d	1	3	devtest01user0000000000000000a1	devtest01	127.0.0.1	0	74	\N	\N	\N	{"query":{},"body":{"postIds":[]}}	\N	devtest01	2026-11-26 02:35:18.728	\N	\N	525560497a89a3421edead941268fa5c3e21adcc51092f13a01769fc97ffada2
804fb94b1557dcb61eea9f7a9dbfde6c	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	70	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:46:39.208	\N	\N	725fdf1768f38d536472e1ac92aee57a3ec6ede58ee3a6b1805ddff70aed77a3
733eb190cafe4526aa8942ac9d4a319e	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	33	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 22:29:56.762	\N	\N	77f751667cd99d61f990a51ed86f87647a318e1f15243cff21b5f32aed3a9134
e16dfab5b3f348c24519171e50c4eb50	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	13	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:07:19.446	\N	\N	35f4cc2bd52987fa62155dd0250c1e03a4cabed4d6680e28af08547112eed728
6ed14826c8edfe9657e0b7f8eea82321	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	15	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:17:08.95	\N	\N	c9a596c2d78ac0963d8c8f7d6658ccd299ebc0d474bc7ee293f7589cc99d5e2d
baf7fc62f6573736671d7bcb709e4b9d	0	0	\N	岗位管理 - POST /api/v1/posts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	108	\N	\N	\N	{"query":{},"body":{"postName":"总经理","postCode":"CEO","postSort":1,"deptId":"af598343d6bd897baa306c5489790bc7","status":"1","description":"总经办(GM)"}}	\N	admin	2026-11-26 00:31:43.03	\N	\N	e4da1d9330e1bd0f5c02b449527a38165247c7d00da9cc9eadbb6d48ed62e283
b99f4ee753a74ebd4f50cde9f34522b4	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	13	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:50:08.929	\N	\N	6f8242ab29c5a12d81e45b85ce107803df09c82ae221713ba2cbeef8625b14d3
4ea03651e56ed6f4a0890af739fdba18	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	56	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:06:46.664	\N	\N	3a269b509cdcd4221d8a9d9bf8adaa8f796050435eda4b095c04889d8ff0d3af
f58d97ee9400a1f6dc18dae310c3e8fa	1	0	\N	验证已失效，请重新完成滑块验证	0	\N	\N	xiaowang	127.0.0.1	1	\N	Edge 158	Windows 10	本机	\N	\N	xiaowang	2026-11-26 01:21:50.075	\N	\N	7ce7ae4e5658170d91f2f2eec1194cc9d517bbf86366409bc168fd1958c6e044
8ac3f1e54ad591178bbb53cd73d014a3	1	0	\N	登录成功	0	\N	0c8c4eeb19abc6c501b59287ba5ae9e4	xiaowang	127.0.0.1	0	\N	Edge 158	Windows 10	本机	\N	\N	xiaowang	2026-11-26 01:21:56.362	\N	\N	624d3549aa162cbe38028601fdb8c4943aa0e60a11edd576799322e13d1ce568
54978c9a14c8831ed4f50dd11fabdb36	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	27	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:35:48.999	\N	\N	cadb219dd58b4065c52d24c2f4c472a50e41e06ee2b8132e0f95876aa05debe6
692e57a879a64f7ed27856c3f0ec0692	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/tasks	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	19	\N	\N	\N	{"query":{"page":"1","pageSize":"10"}}	\N	admin	2026-11-26 01:52:03.989	\N	\N	0a6b48256f7960882bf52d86d9b5369a250b07a963f96c5bbdec447b84e6b565
192d350ceaad61bebe093dcd9591d4db	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/tasks	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	3	\N	\N	\N	{"query":{"page":"1","pageSize":"10"}}	\N	admin	2026-11-26 01:52:04.042	\N	\N	512a4ddec0b1ea6fe8c804172752b611b09ed95a6aaca7f41fc838fc2e50e7c4
0f664cbb1e9ee8750b58ddb5702afad4	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/suppliers	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	12	\N	\N	\N	{"query":{"page":"1","pageSize":"20"}}	\N	admin	2026-11-26 01:52:05.45	\N	\N	2d86f2ab78811b579867c7333f72bf51c81e90355f069486415eb4f072e6ba44
9127061ba802324ed34d392b99afe8d7	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/suppliers	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	2	\N	\N	\N	{"query":{"page":"1","pageSize":"20"}}	\N	admin	2026-11-26 01:52:05.488	\N	\N	f7476a86ef576df95e8fd89bc91ad7b3e71a0ba890055d83a2c06c939778f640
f800aa07bdd8fb154ed2508553e0eeff	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	17	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:04:05.917	\N	\N	c1d595657493fd678d859e277de550eb988c3ae53f3441f048df4d49710c311a
16972a77d03fa08e129aab373b2a6dcd	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	20	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:23:08.988	\N	\N	7bba7fe437deff25256d7ff96caf84cdb7526da37dd55d05ee0a5e456a435312
d209e1cce10dcc11f6fbaa5ef13bcfb1	0	0	\N	用户管理 - PUT /api/v1/users/f4d3e7a811e7d42ddf12e18045075c6d/roles	1	3	devtest01user0000000000000000a1	devtest01	127.0.0.1	0	61	\N	\N	\N	{"query":{},"body":{"roleIds":[]}}	\N	devtest01	2026-11-26 02:35:14.133	\N	\N	8070779c0df9fc530d363b5afc5c0409c65e233b0b37dd1b251ed1a478d9a513
d62b7ecb3b3a85be511fa252296a06a3	0	0	\N	用户管理 - PUT /api/v1/users/f4d3e7a811e7d42ddf12e18045075c6d/roles	1	3	devtest01user0000000000000000a1	devtest01	127.0.0.1	0	37	\N	\N	\N	{"query":{},"body":{"roleIds":["4d4c8d42c168e1ce94b7d2b3c76422b1"]}}	\N	devtest01	2026-11-26 02:35:15.856	\N	\N	54a7b3d0a44402f13e661cecb18d6c6f96ed6f2860b2b7c2641d78731e1916f2
c3e06b4ec7d1f130b022b8f179f782ee	0	0	\N	岗位管理 - PUT /api/v1/posts/3e7ff770b6df3276a36d04bd5e60ae06/roles	1	3	devtest01user0000000000000000a1	devtest01	127.0.0.1	0	57	\N	\N	\N	{"query":{},"body":{"roleIds":["6dbea13a8673eb60c17a59c8381bf368"]}}	\N	devtest01	2026-11-26 02:35:17.409	\N	\N	227ec6ddb5e94f744217d3c9256ed3a6ee33515b8c338a06060e45ad643be110
2fd41969b729115547085dcf50b47cea	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	19	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 22:30:55.95	\N	\N	2551f781c88e19c4c78ac301cda0e64507a6f57931f3aaa0e1a6a05416eb97bd
02a25409c139240bd668bc3cc9281049	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	578	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:07:20.244	\N	\N	44951c54afc41ce7a61579971034f8bb0c873221bc26965932116a4519ae762d
a7b6232065ed914df97d85343a444728	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	29	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:18:09.168	\N	\N	bf243c5baee83eb3dd115326f4480051c4e63bbd362dade9b944945331458b9e
5b18f455b7c09e1e644fdc8f129cbed2	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	109	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:32:22.049	\N	\N	574ca9d581e0a0496857275b40b0ce2c9777a18814d6b38e17026b7e681b8d08
aa057819d625e9f9268c86524582d7a2	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	95	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:50:23.983	\N	\N	45750d862a4af21f05168a7f4e8bb06adfecc7db36eeaa4421c4ef1d2970f33c
5a4b51c3965851611134f8041aa8fc74	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	27	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:07:46.997	\N	\N	520481d2f650dcb69e023b27b1d40e5202b5dc1f940453a03cd28eb15fb0a2fd
b41ac3093f1557814149b5df84532d6d	1	0	\N	登录成功	0	\N	0c8c4eeb19abc6c501b59287ba5ae9e4	xiaowang	127.0.0.1	0	\N	未知浏览器	未知系统	本机	\N	\N	xiaowang	2026-11-26 01:22:45.858	\N	\N	9460cca12e631f6fb26fb98e56d65c7278fc912a032c6672769d0a676346188d
29c39dc357b597c78f1910c36f029203	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	45	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:36:48.802	\N	\N	39e33e0267304e8a18feb8c4574abc5d3ddd0a09f1a1d0b052307eff7e6337ba
4b7cdc810957165a4a3587430fcdc4db	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	44	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:52:27.819	\N	\N	508d7da1fe25f8469be3de34eeb5071f30fd38de38153bed7c1ea3fd8d969b53
e168ed323fc95f08fd3826a6230d2616	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	21	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:05:06.95	\N	\N	561c41c72a13d88c8e2ec3ad809a03840a878ca20914e14295fa1dd47a63d3e5
f352d71ad9367a7c644c75e65041cab6	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	23	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:24:08.95	\N	\N	dc11684bede15c64d00efe678ba8fc9442178704c53075196b160ba63bef025f
7ea8814e6835b1d09f13ae1c73703440	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	18	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:36:06.233	\N	\N	4220be886d9225f3f2e2dc6d18c071eb3fdd8d0530c13c98b17be163c5e7ecf0
5e9e2f293710dfba95052bacac71eba7	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	20	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 22:31:55.924	\N	\N	d9dbdf259cf75a713eefe17ceac7f012c8f32da3473e5090ddbd40aef39be359
498a3fea598f07424137aafc8c2280e3	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/notices	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	19	\N	\N	\N	{"query":{"page":"1","pageSize":"10"}}	\N	admin	2026-11-26 00:07:47.19	\N	\N	9e484549e4a928dfd7aaffc775a85bb2ab185bced8629c7384664ba66f2828f0
3bc646081ae711b5de0e314e62f7846d	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/notices	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	3	\N	\N	\N	{"query":{"page":"1","pageSize":"10"}}	\N	admin	2026-11-26 00:07:47.228	\N	\N	819ec9893db39b292c29d569e4c9ef7b19516d7837c72440e4e5faa8bad62865
7e3ed7676c4ae5352e1f166c79494aba	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	13	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:19:08.923	\N	\N	683a67e822ad63527c3e42bd451c7e647b8b0e6d9205f3249ffd909fa8404e0d
62a2498c03e4255efcc5413a10d93770	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	25	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:33:22.018	\N	\N	dd9de00e4c697addb9910d2f5e7227c0abec8c3ac2cefa0a7c45e3938b97d5df
cd84b793c5f13eacde46236467e90406	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	14	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:51:21.926	\N	\N	8366334c2e198260f17a680ea53e0b2117fcc1493d92f2cce64faaacd809b44d
7679275d3bd28c4ea8ae06eb452ca49c	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/customers	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	6	\N	\N	\N	{"query":{"page":"1","pageSize":"10"}}	\N	admin	2026-11-26 01:08:07.558	\N	\N	71bfb4e38db2c10d5ebcac5f28bc3b5c98c80436e4f8b9f5fe02c096efa4c76c
17aa177633e4a589abcfebb679ef7bf1	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/customers	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	3	\N	\N	\N	{"query":{"page":"1","pageSize":"10"}}	\N	admin	2026-11-26 01:08:07.606	\N	\N	c72d54f4e106b8147fb3aa1e6195cec267183f3f752d75f07ba0bba77f0f58fa
253751bbc50d8f5a4784329d93005daa	1	0	\N	登录成功	0	\N	0c8c4eeb19abc6c501b59287ba5ae9e4	xiaowang	127.0.0.1	0	\N	未知浏览器	未知系统	本机	\N	\N	xiaowang	2026-11-26 01:22:57.747	\N	\N	5834ad13407a363bf98d3582cf892492ecb8ff389ca35a2a0940d9730acacc60
c9ec074b85bce0eb5c0b36de7c9cf47e	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	21	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:37:48.938	\N	\N	d171c494df47f55876895922297ab91e9c41a8e3a1cab8a996da972d984ecd9e
7729a1f1dbc73218a9269763a1dfdb2e	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	171	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:52:56.786	\N	\N	9d84ce3ce05c99671f26e745690d1278ad8f1dda10e8b843b39935764208b373
be289ba8c07f2c023ded58adc5a16c27	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	3	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:53:02.398	\N	\N	e4b610e725273c7b101ad51f6d461be9b475fb34b05e00833d1b7bcff3183304
39d3dc9f2c270dcc1fef0111a19d18c4	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	17	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:06:07.917	\N	\N	fcdf8079dcdeea9c5508ddb715ac8e2b570d08f943d9f5173481cbcb6ba0d7a9
190517b39029beeb056375223cf4dd93	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	28	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:25:09.048	\N	\N	16e0697298cf551e6127cf09d0e5d206e61896b81bd17e10a4044a914d50af17
7c6db026f36391fa3d1f72435603127a	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/mine	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{"page":"1","pageSize":"8"}}	\N	admin	2026-11-26 02:36:11.74	\N	\N	1016ba4d9cbef7c37f947a53f55d400ff0804bafc22cf9970cb13a08a89dad40
02ca0c56e0f5531f813e04bb16f69b3c	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	36	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 22:33:09.42	\N	\N	3bddd9cb2ed344bb39ba2ba4965745ff895f2ff24d640a1e90352cc0fbb6b490
9489b8148f49c3359105dc87d4894c0e	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	83	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:08:08.878	\N	\N	ae041657fb3d7d268ed7d8ba116831bd0403192c24751a776f994cb78f0474dc
aa469841080aeeaab73b023dd8a75be8	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	14	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:20:08.934	\N	\N	1532392ed475f4af9760bec9c729a43c10ad05863c434cf55526bbfaa3dfca9b
b10e722ff7f23d6eba46e0f4c19b85d9	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	14	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:34:21.906	\N	\N	f7fbb04f762c627ff2b13f02e71bebfe9670b14b7fa712d37cd30b18cdb91793
1438e2af76ac6a823968a3e17572b866	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	29	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:52:44.517	\N	\N	215703426329534b48a033c3f74acab59fa33bd3d36853217e3d63f1a6e5f72b
ba832ae5280c6b6ba9bac83814cc9342	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	27	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:08:46.992	\N	\N	0227df1f3992caf241cea9f48b656609dea6ce246951f7b35bf1b610bf36001e
60d0eaa366efe8de8d8196cadfba1491	1	0	\N	登录成功	0	\N	0c8c4eeb19abc6c501b59287ba5ae9e4	xiaowang	127.0.0.1	0	\N	未知浏览器	未知系统	本机	\N	\N	xiaowang	2026-11-26 01:23:11.481	\N	\N	51bd31116e52609a506cd0eddd78c30e02d913e692937f78840734e0731877f9
4d3738fd9a2dfd4c315a7aecfac268ca	1	0	\N	用户名或密码错误，还可尝试 4 次（连续错误 5 次将锁定 1 天）	0	\N	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	1	\N	未知浏览器	未知系统	本机	\N	\N	admin	2026-11-26 01:38:15.536	\N	\N	ef6277d828f547a209a52b9102cc6f4852f3cf359d0a874693f39de55e908c9b
8956801803656f75dc4ea00174f746e2	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	7	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:52:56.908	\N	\N	25bc9c5571ca203ad470b6d82a4b427615a9a0ba6abdb80e5f0d3a4a26ebfdc4
206ad0197fead555b4bc933269b4cb10	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/suppliers	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	10	\N	\N	\N	{"query":{"page":"1","pageSize":"20"}}	\N	admin	2026-11-26 01:52:57.014	\N	\N	2503ebfaf9fe517ab8a374584c7c53494087c06aa7299f6dfba9fb421b4254a5
927189851bc28451e5e696ba50c252fd	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/suppliers	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	4	\N	\N	\N	{"query":{"page":"1","pageSize":"20"}}	\N	admin	2026-11-26 01:52:57.131	\N	\N	fc5d5e4621c1468adfedf33da94282557522bbf3546f8a6c542c566ed60117d7
fa9de9df7d83f68a1bf7be659dbfffe9	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	39	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:53:17.16	\N	\N	f7e4165f61709986156918fb36a8a3fd1f0b6e61b5f47147565edf946e276ce6
e8813e1409c4f546b9e717544b1d9744	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	13	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:07:08.959	\N	\N	81d924c99e0df0da2d125571ddd36b818978ec2bbd83f312b2d2fd8955533e86
51081282cd973505950e3a9b6383758e	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	45	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:26:09.265	\N	\N	38f1bd636d448c3601f425b3c49df96c57e7b4d9a05cc4013e26cfd753b2145e
c8c5fc96d42d757e336372b1414d4d20	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	42	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:37:06.264	\N	\N	5b266e179c81b8c359be2f787def8cc69b80663662f48ca2c35a7a12796f7140
4052ada32aebe6e2603eeba98416a8eb	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	19	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 22:34:08.966	\N	\N	5e6df626974849060f081e473fcfd80df3437b8367782a8c1457ed5c1bbb7d1d
7b274d319c9c2d77d14171f787155c68	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	16	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:08:19.707	\N	\N	50226d8222e352ca313240ac91e4a815c834880a9b432b72738b5a11092a29eb
cb660e43b6a909c195cecbef634f67dc	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	20	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:21:08.954	\N	\N	e8a95e50fdce13962d17e40994d988e382e2ce7f955d0c06106917d66f04f54c
4f620a3a54b1ac22e6f7d22c961d3187	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	15	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:36:00.894	\N	\N	6ad0961700e019a6c4752e835bc941f9527c4a2eba565b75044f4bdd620ef202
9150bf61082d9b4419e9bb72f2ce0789	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	16	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:53:21.946	\N	\N	9f7fb3703c8dd871439df57d6cbd3679651df2bc8896590945e5b6d6aa94c6de
3d384e1cbface6243d073e68be17c039	1	0	\N	用户名或密码错误，还可尝试 4 次（连续错误 5 次将锁定 1 天）	0	\N	0c8c4eeb19abc6c501b59287ba5ae9e4	xiaowang	127.0.0.1	1	\N	Edge 158	Windows 10	本机	\N	\N	xiaowang	2026-11-26 01:09:21.436	\N	\N	f1f19b3fbc0b691d6ed60b5929b6bb64b1c98c0e56d73077a1608c675b5ff763
00342cd5fcb4c60a1d4329f2e4b3a7e3	1	0	\N	登录成功	0	\N	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	\N	Edge 158	Windows 10	本机	\N	\N	admin	2026-11-26 01:26:31.043	\N	\N	1673a9710fd31a525366a575f7efd951baa13feadb41ab3eb86f9fe14d472ae5
8e420f5715f1a30ff77734f83d22d24b	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	61	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:26:31.824	\N	\N	646e880b1676709ea120f775eb893bf6ad66998fad64a29cfcefdf3c308d7e18
5e372d9be604e3dc3b71a697c8cd4152	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	85	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:26:32.152	\N	\N	cfa68a8d498e3ee92be9209ae613789ec6769aeae8e6085affe6644603dcbf06
9204320567c344c22b623692289e9efd	1	0	\N	用户名或密码错误，还可尝试 3 次（连续错误 5 次将锁定 1 天）	0	\N	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	1	\N	未知浏览器	未知系统	本机	\N	\N	admin	2026-11-26 01:38:27.156	\N	\N	40093738950f728f720acff69f5cbf47e384a9c3c154d048cdde61401059286e
10024785d4c3feab92031393143b97d3	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	15	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:53:02.213	\N	\N	581d4eefe25b3bf76b0aee696f3e74248e5180955350651701f203987c50160f
cc0257c18d90d4dcded3e1cb3aa95c02	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	5	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:53:11.445	\N	\N	f47b2bd032af1193ce9e98a5880e7cca039ba36446584514b2737be40dbc5b39
598fef8e525d6609c058a32e110f5566	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	16	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:08:08.936	\N	\N	1dfdcca99ab1ee047c4aa7e69b804504c3a5bc051950d3bc4d786472769b4765
c6969255376f6b4a5ecb835164ed07f3	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	22	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:27:09.014	\N	\N	64d6e1098846af3b9c1a6ad8d9deaca0b8b787f5375f163f9d2be5c054745733
af3620e66cf2a63480cd0a59af67e503	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	34	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:38:07.108	\N	\N	c7be48e6b8e303ca520bfaac3b3347a4d4be6004696afd06336e8de9bc819ded
9a4da78e29baa7ce6d2c3763d99ec3ed	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	26	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 22:35:09	\N	\N	c0b8fddc4cd141afea52565fce7f5a4eca8db800ebbf438805d63791b0bc6783
08b3747eca0de888e9c9c45ccb1a9433	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	17	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:09:08.92	\N	\N	3653cdf1c218e32a07bb227c2f73640e86ef1ee3ed125742b3ab4ed27d6a9d77
4b5b87e6d7bf50476e08eacd25875d8f	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	60	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:21:19.681	\N	\N	fefafbb3668eaed17d5e575942a326f65f10edfd20e421685c86e5c7f471f177
05e702043f5037993c6e601501809198	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	15	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:37:01.909	\N	\N	0cfdd18274dda7e9dbf50a22f2905cda5a3363e8983b91c09cdc53144f6da2d4
a27ff6c294bf0a602cb440c0ec680bb5	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	14	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:55:08.915	\N	\N	db385ee20ca6cf8e6af0a64392e1039cdb41b1c025dd7ecc9620ee6f70da4b31
64e188591b5c336b1d80d1346fc210e1	1	0	\N	用户名或密码错误，还可尝试 3 次（连续错误 5 次将锁定 1 天）	0	\N	0c8c4eeb19abc6c501b59287ba5ae9e4	xiaowang	127.0.0.1	1	\N	Edge 158	Windows 10	本机	\N	\N	xiaowang	2026-11-26 01:09:46.888	\N	\N	23f330e9f0004b65d5c398af6273b63aba80aab4affca809ab77ca24d334c3d1
395abb86243b6af8b9f4ef1d51b644e7	1	0	\N	登录成功	0	\N	41c5e48c0d6d1081bf9f4887f6d47606	fin01	127.0.0.1	0	\N	Edge 158	Windows 10	本机	\N	\N	fin01	2026-11-26 01:27:15.696	\N	\N	6806bf27f3d7afefadf415d895c027fae62d55292f046a1fdf5fba0aa058193f
c7b27929902b56485c9292f0b5473f5d	1	0	\N	登录成功	0	\N	0c8c4eeb19abc6c501b59287ba5ae9e4	xiaowang	127.0.0.1	0	\N	未知浏览器	未知系统	本机	\N	\N	xiaowang	2026-11-26 01:38:43.239	\N	\N	ab868606046c0a7562728f206265c3ea1a49354681b90e5d4406a73e3ca2d8bc
0de9735536b20a2f40d05244965103fb	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	21	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:53:11.628	\N	\N	8221244314e790741d8ab960ccfe04948f7b44922adc5420ab97aaf859f9b092
af764eeb97e08c322d29679554a9040b	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	14	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:09:08.903	\N	\N	17feee6ddea152894546baf0b16253d627f158ca648c682933a1f80f69f2a2f2
a58792150bac44e7b7a6c9d01a5fda13	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	28	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:28:09.002	\N	\N	31bf711046c3743248b311a009dee9f71a96c7b048b9d0033bfa883fd3ca50b7
5829a68414331683317778a7becf99b2	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	34	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:39:06.286	\N	\N	fc362260f8b62d138e1ef22ad695c65e724de1b0451a1f71d788f05e5647add5
786c29ce7eab7158edf4c12bf51637fc	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	22	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 22:36:08.958	\N	\N	5cb18a46b7aacffb73935c8b8baa9d82ec7c445c57528c58c8ecd97c5b8f4416
2decacea99950c175edcbd1747c67a39	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	37	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:09:19.607	\N	\N	05033802cf8d20ce3cf0b87952c59a6b92c1b3395b0abdbe430aab54249cfeb9
f71cb33a377067e9859581817eb1edbd	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	16	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:22:19.609	\N	\N	697788e4056cefb54d26f9e9ff994d347077c8c3b116c06729d01fcf314a82f1
de04c58ecb23b1de5447a2431aa03cd6	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	26	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:38:02.952	\N	\N	5766dfb2bd0084ab8ffaf05fa6d0ed95b22d4dd5444cf9a43818e011b81c5acf
08dab63569546198cbe18803326f0a90	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	14	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:56:08.936	\N	\N	0e35d845d74d52340772fe101996bef73761cb1215cd0cc9277c2136caede134
d3eb145dd7b34a211b7f0150e0e764ba	1	0	\N	用户名或密码错误，还可尝试 2 次（连续错误 5 次将锁定 1 天）	0	\N	0c8c4eeb19abc6c501b59287ba5ae9e4	xiaowang	127.0.0.1	1	\N	Edge 158	Windows 10	本机	\N	\N	xiaowang	2026-11-26 01:10:01.356	\N	\N	527a8780c4fb182f361d97fa8de7bb63eba0fd3d840bcba0fa0304058448f71b
184cda9368feb967a71fb323b19f255e	1	0	\N	登录成功	0	\N	01bc4b87600d348e591cb18ba87dbcfc	mkt01	127.0.0.1	0	\N	未知浏览器	未知系统	本机	\N	\N	mkt01	2026-11-26 01:27:22.065	\N	\N	ba2f7a5875da33bf796cda044a559f4ee1cdc45d352077a66c5131c967457a6e
a98095378d24b755946e395f9f02423b	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	15	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:38:48.862	\N	\N	7e8394cf93b86bf979a786c8e0957ad3912e1d125eacce3bf711bc44acc1d541
63009f5c53281899bb214c7ee95abeb1	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	22	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:53:17.484	\N	\N	91c83cbe270765a8ab1399a49cc28487bc803b7b0c766c07632e72efdad3a112
2937a8add7915b6af15f76f3bbf474a0	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	14	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:10:08.935	\N	\N	ec124d5eab7b91396da8cb4338729499836ceb8306c8fa801e1432efe78bf7be
dbcd4aeaed38ba825371749e020dda47	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	45	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:29:09.19	\N	\N	0de23cebc2d79a77842089705f7d153a2083b004690a7278fb728b4d64ba0e1c
db657a775eb888a4e1fcd2577b9bd115	0	0	\N	岗位管理 - PUT /api/v1/posts/3e7ff770b6df3276a36d04bd5e60ae06/roles	1	3	devtest01user0000000000000000a1	devtest01	127.0.0.1	0	42	\N	\N	\N	{"query":{},"body":{"roleIds":["4d4c8d42c168e1ce94b7d2b3c76422b1"]}}	\N	devtest01	2026-11-26 02:39:22.989	\N	\N	d5dc9d0f1a83b4ecef2d0919f18125ef648b691786e30a6a7c814d28064f1987
a9bfdb778208b716da765ffa32c3b108	0	0	\N	用户管理 - POST /api/v1/users	1	2	devtest01user0000000000000000a1	devtest01	127.0.0.1	0	200	\N	\N	\N	{"query":{},"body":{"username":"posttest02","realname":"岗位角色权限验证","password":"***","status":1,"postIds":["3e7ff770b6df3276a36d04bd5e60ae06"]}}	\N	devtest01	2026-11-26 02:39:23.535	\N	\N	9304428d0db3f3a518514a5d424ed33df7d9742cb646aad374b11888f3cae249
75b7ec2aa7483e1118aa8460090e8c4c	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	17	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 22:37:08.935	\N	\N	f0f791c2d95135e10cf439804d56d6a76ec51b5cccac0078a0d769ebec155b3d
4578764db445559a1fb10dc79a3cf5f7	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	17	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:10:08.928	\N	\N	c5805107776da1e82315694fb5382a2c35dd71a2b07aa55f8168bc957234fe15
c6fb23b975eab64e5cf84038ba3c8bb6	0	0	\N	岗位管理 - POST /api/v1/posts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	1	20	\N	\N	\N	{"query":{},"body":{"postName":"总经理","postCode":"CEO","postSort":1,"deptId":"af598343d6bd897baa306c5489790bc7","status":"1","description":"总经办(GM)"}}	operator does not exist: character varying = integer	admin	2026-11-26 00:23:19.354	\N	\N	8a94325020fb9a0e6849bd3409a89909a66a08837f2f7f54e9ececa0200da614
20f329219a5db1429f55edcb7c078646	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	14	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:39:03.897	\N	\N	b9fca78786a04816aeda8e09acd02172ce1cedc94a6a9d33ae07ed6fb775eab1
adf083cd07beaf372b176ba0fd2b82a3	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	16	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:57:08.904	\N	\N	4aa6c11fab6b1079a207c39a85a7e94c02ec1a4fe3eeed7e6c9b26eb564ea4a9
ad33d7f04434956935fcd17b32ce22ad	1	0	\N	用户名或密码错误，还可尝试 4 次（连续错误 5 次将锁定 1 天）	0	\N	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	1	\N	Edge 158	Windows 10	本机	\N	\N	admin	2026-11-26 01:11:20.245	\N	\N	d947a496e6312220cece85486a32b6e7a167cd689d283fc5c19aaa9c531e9c2b
ae2bd33d918a452357906deab1a68dd5	1	0	\N	登录成功	0	\N	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	\N	Edge 158	Windows 10	本机	\N	\N	admin	2026-11-26 01:27:51.373	\N	\N	f3b50fc6876b449ea1e536ffc11fbea6c085b01d6528c9533e5723dd97497930
3e2c75a7f0ba7f621e29a4a6c359e3dc	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	21	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:27:51.66	\N	\N	27992e9d032da156ae05cab7f80a9de7dbdf94728c9f0535bebf0362cbfe903e
d7a37bfa4c591f136e16f52d5e181e70	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	4	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:27:51.892	\N	\N	80d3a656521772d37452b1acfe730a1afb05375253d361418d95ce174cb9de3b
bfe4e7db5b4f9ee4e1404de6bf279211	1	0	\N	登录成功	0	\N	0c8c4eeb19abc6c501b59287ba5ae9e4	xiaowang	127.0.0.1	0	\N	未知浏览器	未知系统	本机	\N	\N	xiaowang	2026-11-26 01:39:48.381	\N	\N	aaada61e4360670a444bdd735d84257e58d28f40994666ef1f0708a6bf2218cb
be3cb0fe2a277cdff22f910cd0a16e36	1	0	\N	请先完成滑块验证	0	\N	\N	xiaowang	127.0.0.1	1	\N	未知浏览器	未知系统	本机	\N	\N	xiaowang	2026-11-26 01:54:02.809	\N	\N	a43316ee87c233324731e0d4e602b18251597626989017c9ff43a0baf6721874
bd42b95378b9d0a82b2e463545625437	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	12	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:11:08.948	\N	\N	e22562c4df4be6d7532fd35929f10d3dfa7aa9563a0c098ff274ea760d0f697a
3b4a7f9e574d5e7ea42a6f8e4bfc3c39	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	17	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:30:08.928	\N	\N	2d2ee0ab700e233a55ef14c70a62e3e014ca5c22b11b2d597d7d0918009942f2
29f9a09cb3e3e7a0c0a3ddfa46af7686	1	0	\N	登录成功	0	\N	087cf8cb96c0dba91519c3194a01a3e9	posttest02	127.0.0.1	0	\N	未知浏览器	未知系统	本机	\N	\N	posttest02	2026-11-26 02:39:39.119	\N	\N	c0ddc6ecd8b1c26702e4ccd099ea7bc32f8785c7913ba9c622b6d331a3f3a3e6
b0a9e24d494f3e8609b3b7ea4aed103b	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	28	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 22:38:09.019	\N	\N	d1be7f2ffe17ec8760d890ce912585e3fe3cd999000841e474b99e004cce90ea
e408efb032ae55ff79e9e53c01deb841	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	36	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:10:19.616	\N	\N	abee5256c6a7d851e805f71a10c41edfe85b27fab9fed95a0cdf64d941fc9273
02f98ed8f535d391ffd88dbc6556c62d	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	24	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:23:19.615	\N	\N	a0761bd77a329153e80691d200ecf3002a2d759d49a430a16b8dcc5a19995a54
716666b77d3f36d7d3b7cd680de20ba5	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	15	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:40:04.891	\N	\N	aa1be653ef6f840ab65653a1a7d6d9dfc67f98136571b1ac7518ff311276abe3
03bff529fa6051a40ec7c28219d6ce1f	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	15	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:58:09.091	\N	\N	6013f9143da5793c879378bad3bc57daa0a0842d607a9b918d36038d5c9eff13
204aba5a3222d79ef0f35ca2d6f7bdae	1	0	\N	登录成功	0	\N	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	\N	Edge 158	Windows 10	本机	\N	\N	admin	2026-11-26 01:11:40.603	\N	\N	010e5cd7487fec56e94dd0b76565b9ea58e28addbf889c0c9e6a37af1f1222f9
4880751979cc7b2426f2132237af3aa6	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	128	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:11:41.503	\N	\N	e33830da097ca870c9ab4a454ab9e30e6a8d36c2386c4f9237d721fda2b7bb3c
f5c6310ea09e70fd4a0e6c198c551500	1	0	\N	登录成功	0	\N	01bc4b87600d348e591cb18ba87dbcfc	mkt01	127.0.0.1	0	\N	未知浏览器	未知系统	本机	\N	\N	mkt01	2026-11-26 01:28:17.275	\N	\N	725bd4dbfed64ca2e01c86196211883ee6ff08a99d921886d5811c0310c9b260
8e49cc9d71c402ae7c7ba2b9cdd9f169	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	39	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:40:02.356	\N	\N	9c04336f0ea6f148972748dfcdeb042a576993decab58f6d1c312b2c484bec91
125de19f12163f5890694e022b5f6cb4	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	40	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:54:17.478	\N	\N	ec3a3339e9e6393bc978e18c2a70115ceb30bcc51bb5b50b06de14de8e05e91b
3c9cede60c9d19f054d03d6e38e863cc	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	20	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:12:08.951	\N	\N	aa5fa0aea1b45d8d762cd0d55c485b445288c8fb90984ccff7f096d122237cba
25eeedfc09cbce3808dda7244c45daae	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	52	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:31:09.151	\N	\N	36afb5afc81b58ede9902b24e8ff9fee6f8b48aba216a0bcd343745d20d9a382
cbf5116db61705057d5e3eab6e1c58a1	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	23	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:40:06.942	\N	\N	800e2e8713d3ca2072b0ed12af4643f7c45cd3d55a2683fa23275255c4c819c6
9969e0dd2b92b9f7378881bee33ac9ce	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	77	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 22:39:09.733	\N	\N	55f0711184a286bc33b0715133af01e92f9c3827c98e1ba531f983b96e590884
1dbb4d177f820436369530c80afe9cb1	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	17	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:11:08.923	\N	\N	61b2807f6bd7904c229c41ae1f6498bd4dfe416a68a80b31cbf970702deeeb86
bf0108e820eabc8923ccc0d11a24bbb3	0	0	\N	岗位管理 - POST /api/v1/posts	1	2	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	1	47	\N	\N	\N	{"query":{},"body":{"postName":"总经理","postCode":"CEO","postSort":1,"deptId":"30b6686380c4ad34cfadaaf525b35905","status":"1","description":null}}	operator does not exist: character varying = integer	admin	2026-11-26 00:23:35.769	\N	\N	f41aa9ba030c42172cab7bd76c749f919c729fb0a056c94c3d7fdb010b4e7de9
3718d0c268e83c489f1d3782e54b03ff	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	17	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:41:05.909	\N	\N	89d099e8a96e1521e4c31f452f0d96bf09c98d761a85ab382b665fcdde2a6850
a836cf590b697270dbd407bb523898d5	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	15	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:59:08.97	\N	\N	35776ea4d688a96a5e180671629329321108fb87b99b42012be968b35bc2b0c1
23850ebf58e99b93f1d7b39e0a0e683d	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	438	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:11:42.212	\N	\N	ba844802a146af00481faaf129b98323c390f838edf24500c5978f4254f3a99b
093d311855ae1701280a0204bfaa0046	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	48	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:28:51.836	\N	\N	62afa100d7703a7d5959bf841977b5d8bf9462085187cdb50e7d047ea3db0556
f4ab09f0c4c2aa1185e5ada304cfce6c	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	3	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:40:05.276	\N	\N	32b4639bca9af1aa932dd00b0821798328dfb48e558c8b4e4d22c35543fa9d80
3e63d308f4da9b5fa463f5015ce8e93d	1	0	\N	登录成功	0	\N	0c8c4eeb19abc6c501b59287ba5ae9e4	xiaowang	127.0.0.1	0	\N	未知浏览器	未知系统	本机	\N	\N	xiaowang	2026-11-26 01:54:43.495	\N	\N	7cee4365ff3df42ecd87871ed87cdbc34fa7ca4aa88ab5f6175ff525e164a008
1d50987649f29f0a280cc779da493266	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	16	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:13:08.925	\N	\N	eb943c6877016a2b8e5b9d64d106726753649cd208ca4852e5c18088d0b9b764
54aae8d22553c7e4b89ec6231bc9b16f	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	53	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:32:09.389	\N	\N	371a407d424da777264bec21b29c0487d83d4ee495a9abdb7c1a9d3c30cdc5d7
46de4485374c9fa9d6b65ba476634c38	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	22	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:41:06.965	\N	\N	e755d4394c5039981c5b58083f1bf0ecf772874440b9d14311581d685db976a7
8010086eee2bac6767490de322b689c9	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	88	\N	\N	\N	{"query":{}}	\N	admin	2026-11-25 22:40:10.619	\N	\N	7cd8ebab52973187c92aca4d472fabaaa7f0ab63bd0425e4007a566c5166fa5f
b090ccce1cfab888324a5518a14c5272	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	60	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:11:19.656	\N	\N	32d4a03708aaabb66889d12cc911edfcec9ac89696717fe8b37feacec3b931e7
0c89bf6518be948012a47af5a13ed4b7	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	28	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:24:20.053	\N	\N	ebf9a303d7766323569bf071f12f4f7a2a3b751e473815769e2215880367fb73
2d70b73ca20de0cb05aeb18ab644e36b	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	20	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:42:06.968	\N	\N	5492815dbfbc6342c2ce3076a8d6a8c8173c26ee97b62cf77aa666eedecbef15
5bfc926bad3b1f031847afc59da325f8	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	19	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:00:08.975	\N	\N	a4c388a13ebbd67902e84b5b05ddb0d329f0f2766feef64582b7e300bfede4c5
dc587f10ba044cb67fdb61048ccdc6ad	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	50	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:12:41.459	\N	\N	8f04b1382da7e1ca284af5aa2f864b42bbae205c34ceef56409d1e9dc3fcabea
120a6557ad0c2fac7664d42dfa979b5b	1	0	\N	登录成功	0	\N	01bc4b87600d348e591cb18ba87dbcfc	mkt01	127.0.0.1	0	\N	Edge 158	Windows 10	本机	\N	\N	mkt01	2026-11-26 01:29:44.068	\N	\N	771913e166d531ff59e6cfc45ab2e9f3568591f33f5b6d4e96b2f01d920c8046
314ef20b02a31f2b307aba936f712911	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	8	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:40:05.511	\N	\N	f9bd04d6cc0f7c3e00beac8db91b680dbfa8468385079f66f8f0ffb4716d01dc
8ed39c24ff66643aa149969a3be85935	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	22	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:55:17.977	\N	\N	a549cc4d42afc2175aa76480cacd9473b4c1e5aae856f0ae5bf0c36317dac667
92c6105df6bd8c7cdda69b6b6dd41385	1	0	\N	登录成功	0	\N	ca81b8e211353133e77bc75b49913d89	tech01	127.0.0.1	0	\N	未知浏览器	未知系统	本机	\N	\N	tech01	2026-11-26 01:55:25.569	\N	\N	24f94395d8343a42019ff5ebe0099dc69b2b9fe24db9b6fe217c91e61987261c
c4dcca369ec56e55e155b2ae6186f3ac	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	16	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:14:08.931	\N	\N	f3b39094afc7d533db0757cd7e4061dc444387d55df43e7a6e0bc5516360af4f
e72b53b5f2fa3ad5686adc0abd0e1750	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	134	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:33:11.033	\N	\N	81a030e7b3e35b03244c7b6fb44a2a2a440b08d9875d047a80e3f8f09a3f8a21
5370725a452538865801b820bf7f4e83	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	54	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:42:05.123	\N	\N	e83c4ea4bcb2d05eca6e8ad28de574a52e138eb0cd9aeae253338a4a8bd55c81
93804754e932c3da3dae91fb228813a0	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	5	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:42:05.373	\N	\N	4f493aa57e75534284f09ec33e185cfb761b5778967f79643602e96c3de4ce3f
36000f9235a4a05046e31ec0d0594f91	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	22	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:00:30.961	\N	\N	7f4fa300b6e287672c3aea0db7de81441b698c917b22396e8a2dccb6dee14571
4e7b6c8ab4a6d595e778ce5c2060f4ea	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	16	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:12:08.924	\N	\N	2e82bd488ed9c22cfc181cb32f0259d4afb8c313533c075da419b0dc471dbd0a
a6013dce464e96e33624690ed23d75af	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	31	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:26:09.081	\N	\N	526de383128cff0f0ff92b91736bd18491a069baac2fec4506d887a63771885d
114354d75f297b1761c6d9eabc8d5267	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	13	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:43:07.89	\N	\N	f078f5bf92c02d9e8344eaac65e6ff02d669b030accf4b81feef43bf6b73f2d7
672d5f6099efd18d2efc1088ee064b2c	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	20	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:01:09.107	\N	\N	baae36d8177aaaf349c86f07810e3d8cea6013921b481f0ae7220c043828f335
d9b2a1b0d78bc7afe0ad3e39e18f6bee	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	47	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:13:41.822	\N	\N	2fb507a94d941152b61cbd135d2a8199b1f8021e8e9b801b9b987e5bb0dd6804
d851ce5b45e283d4eed958eff4f2c2ad	1	0	\N	登录成功	0	\N	41c5e48c0d6d1081bf9f4887f6d47606	fin01	127.0.0.1	0	\N	Edge 158	Windows 10	本机	\N	\N	fin01	2026-11-26 01:31:10.782	\N	\N	242eb559f470ea431adac66dbc9d3457bf54ba896c2a62c5f206e9cb03dfa84a
69618a2c8ccdddc0bfaf1abe6aec09e6	1	0	\N	登录成功	0	\N	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	\N	Edge 158	Windows 10	本机	\N	\N	admin	2026-11-26 01:41:02.84	\N	\N	c4005284901ba46b90db0a95f4477deb74be5dc80ffd04038766bbe0d259e9ac
5c0d315a1b71cf1b6622d9e9efa25a4c	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	37	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:41:03.135	\N	\N	1ec8a0f573b77b4b3df9945e1ecf2b2b60b18eb7ceafdecefcf397fba892301a
406bf36692e1ccd9b6a5c312d0cfc336	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	9	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:41:03.29	\N	\N	3e69a5a87ffdaf2af8160ace9d6d8e049fa342d3672b0bc6e6febfacee34ead2
bb69b2b332c8179870bd5c20d0db6f26	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	20	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:56:17.934	\N	\N	6773f1aa237b9eb57ca4cd56b1b8a4d5c7f24337595c0e2ba767c78e133c5612
b846fc6366aa98e3763d4d03d51f70e9	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	14	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:15:08.901	\N	\N	6613dce1b0f85512f2c594446eb1fe56778433fb41dd0bc9446a65003f792fa6
0e197794ef7e9c91ccd1d905653beee8	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	45	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:34:02.818	\N	\N	f552ce6cf93dfbbf01ccf1cb7459c2cab266dfe1c0120bfc6a89e57e1a6a3580
05ca9827bfbb12a87010885414c093be	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	35	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:43:05.128	\N	\N	44dc19c98fa18bae374cd4d7824990a100531af72f19856e270b848af3aa2264
0e3d1fd72c2d4e981022d479720393d1	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	15	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:01:30.914	\N	\N	b5f1316399526ed5e44ecb508542c449dd5a56a209f481cb77896c414767c25d
5bf204869dcec546dfd38c439af844e5	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	48	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:12:19.633	\N	\N	da7b252357d1131fe35f1a539c0ed69d68c92d72cd12b17f9e7150a78126f475
ed2205226d08a693778f66944d0bf421	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	51	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:26:19.829	\N	\N	b928620c63d18e93708f8214426c4b7bfae6a16263eeee57b28835f5cfa76c80
1578f1c87b530c81f1e53522a108d310	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	14	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 00:44:08.917	\N	\N	f274ef12e6c83f0a4a65e1e25df7281ffe9b9ef39cfa7d33e53fec3b2705c182
995d67edbd30d75b8ed57fc424405806	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	68	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:02:09.407	\N	\N	a3ca7a40cd8148b6e3d1e7e9bc9eebea531f3a2b774623bcc1c88e1a9d142ddc
2031a53b5b68587f15b75381e4af9095	1	0	\N	用户名或密码错误，还可尝试 1 次（连续错误 5 次将锁定 1 天）	0	\N	0c8c4eeb19abc6c501b59287ba5ae9e4	xiaowang	127.0.0.1	1	\N	Edge 158	Windows 10	本机	\N	\N	xiaowang	2026-11-26 01:14:53.883	\N	\N	46e2ba06387df6e136f55ede8c9ff2eb7e05984232e9e1ba49a44adb7a42e995
489f915b85832933089e506bb814f88f	1	0	\N	登录成功	0	\N	41c5e48c0d6d1081bf9f4887f6d47606	fin01	127.0.0.1	0	\N	未知浏览器	未知系统	本机	\N	\N	fin01	2026-11-26 01:32:25.346	\N	\N	fbec4d6f1203a32da821431f2a14aad2a7b221de0a3604a938fd869290060014
68ac06e96362fdba179196e2115fdd20	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	19	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:42:03.286	\N	\N	5de56446bde957e591150f1bac56a6379e6f3ca84d7aecdcb4dfb79a8b5f311d
45dd7d947a19903447213db3867e9f4f	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	22	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 01:57:17.934	\N	\N	2d531cbcc135b6d1a3a566042a43acd24086a4b82b4203220b8633f7321690fe
f87fe00ee2b81c648c98059b5187bd4e	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	18	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:16:08.964	\N	\N	2fbe4adfa0040a99a83744bd79ff0af450cd6a08eb36d32f7b6f1f6a4008c33d
8501c40041d276fdcd8d8634a0d4ec52	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	21	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:34:06.17	\N	\N	39f8bd9cadbf87ee582c1c04cec25528df895ce179fc32c8cd8d8ea91d4c3bec
efb8ca6ffb9e01350938ee48c11e1df1	1	0	\N	登录成功	0	\N	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	\N	Chrome 158	Windows 10	本机	\N	\N	admin	2026-11-26 02:43:29.759	\N	\N	243398003d25859539743451945e5969bb9946cfade556bc4f900d45b7098e9b
3d0bef7d03c2343e3cdd879006854432	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	250	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:43:30.262	\N	\N	8929498eb34fe0c836be8b14e48a283973bf930a974276414992340a98135050
7188dcd25288e3e3599bcf3f0aa6b714	0	1	\N	平台视角审计 - 平台视角查看业务数据 - GET /api/v1/messages/unread-count	1	1	e9ca23d68d884d4ebb19d07889727dae	admin	127.0.0.1	0	36	\N	\N	\N	{"query":{}}	\N	admin	2026-11-26 02:43:30.464	\N	\N	688f2c009ed0daf412c8e521c591f166e94e6d196a33f3b0c93e153af0519f51
\.


--
-- Data for Name: sys_log_change; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_log_change (id, tenant_id, table_name, record_id, field, field_label, old_value, new_value, operate_user_id, create_time) FROM stdin;
5d6dc6beb6a136e828bf2c27d726aa98	0	sys_depart	58cfac62e97a7e010be281db024ac135	departOrder	排序	4	3	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 17:34:50.365
1c5df913c8f53e12ca1f53a6dc876357	0	sys_depart	816d6207c9bf763e331b7a73bf192f12	departOrder	排序	9	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 17:37:15.523
0fd4b95aed72bdc7e7def022f30bfa1a	0	sys_depart	816d6207c9bf763e331b7a73bf192f12	departOrder	排序	0	9	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 17:37:22.769
1f6bf65d98d0528ab5c5d1053734ce3b	0	sys_depart	9ad8689d847c849d14459b9749d561c1	departOrder	排序	1	2	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 17:38:55.975
b4e1c14dfbcbecab3d45c8585220e3e5	0	sys_depart	c61d7eeb14bfc68321c7af4db06b6f62	departOrder	排序	3	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 17:45:31.054
b66f43ecebe6c1d98aee6d4ee91787a6	0	sys_depart	f026194db425743c7cd02d3ed50deb67	departOrder	排序	10	9	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 17:56:59.09
9504dac782c28e5437b59bf274469d33	0	sys_depart	2854ec06659a0c455a77e6f310cc96c0	departOrder	排序	3	2	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:01:53.136
12cf08da948fbed31ab16b5fcbec6a47	0	sys_depart	af598343d6bd897baa306c5489790bc7	departOrder	排序	0	1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.527
6b1f9d74713c71b2e2f66b37eaf07ea7	0	sys_depart	064719832c25df4ba5f58bfbf8872284	departOrder	排序	1	2	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.635
f81c6e06e2d30d10243df0749e94cacb	0	sys_depart	fc237c66532784bbc636f47e7542955a	departOrder	排序	2	3	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.64
db3499a0401b8aa93ade7c9571e7600a	0	sys_depart	327938411ddc10ff9cf1f30bbee3b797	departOrder	排序	0	1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.645
a0fffb5187f46423413e278cffe657fa	0	sys_depart	416253c3de1187227e36288a728eb1e0	departOrder	排序	0	1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.649
8a7bfbb7b0a4826790b67e47ad9afd83	0	sys_depart	2128fcf7ff6c60920e2294e2b009b5ab	departOrder	排序	2	3	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.654
ff2537b59a76423b35f849228f713e32	0	sys_depart	b8453f144534871988e733ffbf2cebf4	departOrder	排序	1	2	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.555
8d843eee87f003af6f32d8cfdc98f5af	0	sys_depart	2854ec06659a0c455a77e6f310cc96c0	departOrder	排序	2	3	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.582
26838c682867b53bc3e9461112a8c3ca	0	sys_depart	30b6686380c4ad34cfadaaf525b35905	departOrder	排序	0	1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.674
c804a02d3739190ad9cc81bb916c918e	0	sys_depart	f366f71504c6b1ec8d21b93924f09b0d	departOrder	排序	3	4	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.61
541a3e4c7e688c18d12131de40f0e04e	0	sys_depart	32c636f441f362d0ecbd3cfc7173ba70	departOrder	排序	1	2	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.703
4c1f538539f5a4981ff52961c0f9f4d2	0	sys_depart	38597acb8e812274d601af864c1e6c5a	departOrder	排序	1	2	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.647
762ba55f85323d8d59f41440d417a036	0	sys_depart	128414f99c799b60253d912c371a7616	departOrder	排序	2	3	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.731
6e77018112629c8bf2ac547900df064d	0	sys_depart	555f8f0307a3d92dfa3923b58889decb	departOrder	排序	3	4	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.75
d3a4eefa79e563a832d9ac7bb1a9e3b5	0	sys_depart	8ccf8ae1828c7c9f9b9933ff3590f674	departOrder	排序	0	1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.767
47f0903091ae6e1d33845fac42908e4c	0	sys_depart	ec46d2554ec6745bd25c89eacbf2838f	departOrder	排序	1	2	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.78
f556e7368dac7fc94f7ae4ce2930f02f	0	sys_depart	e3c7a43c3bf49f56d6ab700e270e1114	departOrder	排序	2	3	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.791
2a56a4babf9805156e77caf9c2ce2bed	0	sys_depart	531503f12d9cdf729d9ce8ae535ca6ab	departOrder	排序	4	5	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.801
7ccf7d277a10a86dfc82f972f6c29650	0	sys_depart	99a0d20e0d987922cf12a549625ad4a6	departOrder	排序	0	1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.814
424869ba49aca3c27510203cbec69eb6	0	sys_depart	d29d3723af11ad4111c67ad54fbcffef	departOrder	排序	1	2	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.827
dab013703fc52b33df13ea9739097a94	0	sys_depart	760de6f8fb3aa4be8e60358dfbf91fec	departOrder	排序	2	3	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.837
43923035e6ec445f07c780e7f6defc56	0	sys_depart	1577baeb20661e0ba522c60351c101b2	departOrder	排序	5	6	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.849
d7ca83241852f9e479bac7427bfc2f9e	0	sys_depart	eccd62d7565486bec4bf7097af9e02ef	departOrder	排序	0	1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.87
e67052a0dff88cc3a69b58d1ff9c77ab	0	sys_depart	d6233d450450a6fee112aa0d5bf5a111	departOrder	排序	1	2	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.881
5751dd642d95c0c9eab81dcaea0823d2	0	sys_depart	4fa21fe679ec8a87f089a3f22302cbbb	departOrder	排序	2	3	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.896
0edb47ed4ed8d7452ec44703a1f624d8	0	sys_depart	d3e1489934c2d5d5cf10e4cd614c4404	departOrder	排序	6	7	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.902
815f99868a910119b16332946162db6b	0	sys_depart	d03c1e5fa900c7cc374e215fc5aa03c4	departOrder	排序	0	1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.919
d71e809aca0f5892fad6ce93b17ed7c8	0	sys_depart	b901fdcf1f05ef030a4d8611e34c8884	departOrder	排序	1	2	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.941
520af26251bfddb8c359f5c143aca086	0	sys_depart	0805397fc9ee27797f78e7f0e517fcdb	departOrder	排序	2	3	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.962
4cce296c8ef839bcfd01ac4261eadc49	0	sys_depart	5be257cef78d16f621e7b86a0d646e0a	departOrder	排序	3	4	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.976
f0045d89547252805af8b7243584bb3c	0	sys_depart	1fb4b0372ab1925f031895b23f3440b4	departOrder	排序	4	5	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:19.998
110af112b2fd5af35e4ccbdd954c2d09	0	sys_depart	5db52b767a1cbd831537d81976df3a95	departOrder	排序	7	8	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:20.017
e5adbc8a80dd8ff28b86442ff29f6c3e	0	sys_depart	39d47b2eaa34dd6aaf2f4a77ff8b549d	departOrder	排序	0	1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:20.037
570a125d2862e3a8f284e554d6e48804	0	sys_depart	64ebf0a472bdb5fe68c96b693bbd27f4	departOrder	排序	1	2	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:20.059
27d7063c6d4bd7421f25014c0e82cbdd	0	sys_depart	18beed4df928b66aa37e54196b867101	departOrder	排序	2	3	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:20.086
bc1eea0ce5a64529391fbaa94900555a	0	sys_depart	4e390600751ce578102a6d3903a7c2e8	departOrder	排序	3	4	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:20.111
87068f95a43ba087da69ad53c1d82c1f	0	sys_depart	6cae4d898c1073b39b0b0ddd5364c928	departOrder	排序	8	9	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:20.126
ed681f2669e904bc71c4c1c926d13f9e	0	sys_depart	55d28a2e23ee0d540765d6f275c137e1	departOrder	排序	0	1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:20.147
e0d40c6ad10cf374406c6e30b627c205	0	sys_depart	b92d77cc5bb247bc30ecd8af790219df	departOrder	排序	1	2	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:20.165
1f46d3c940ee0e90600c74877eb7c6a4	0	sys_depart	2aa12fcceb1e0b9c21e35780242b8884	departOrder	排序	2	3	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:20.18
9ec7266aa11d9288202f7b679414cc1e	0	sys_depart	5bbd2dc7daee73642b67585ec08c40ef	departOrder	排序	3	4	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:20.202
7908f3e17da74444c19175af3f5f4842	0	sys_depart	4c5e87295e51cacc865bf92accb55875	departOrder	排序	0	1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:20.236
f9ef80ed47828a778d5891e9b1b8b1fa	0	sys_depart	f026194db425743c7cd02d3ed50deb67	departOrder	排序	9	10	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:20.223
26a857f5ef286aad21a6b9aadd5e42d6	0	sys_depart	bdd29ce3d7f07a087f73ee2aced413f2	parentId	父机构ID	4c5e87295e51cacc865bf92accb55875	f026194db425743c7cd02d3ed50deb67	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:36.845
58a8adec8f496141fa85e75b45d17e7b	0	sys_depart	bdd29ce3d7f07a087f73ee2aced413f2	departOrder	排序	1	2	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:36.845
8da36262e325410041522e23e0d47e68	0	sys_depart	bdd29ce3d7f07a087f73ee2aced413f2	orgCode	机构编码（唯一性由联合键 (tenant_id, org_code) 保证）	OPS_CONTENT	OPSA02	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:36.845
60972c4386f1c50ac9befcbb098f4988	0	sys_depart	4c5e87295e51cacc865bf92accb55875	departOrder	排序	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:47.416
65c424a7f835a6fb0619db57e4d614bd	0	sys_depart	bdd29ce3d7f07a087f73ee2aced413f2	departOrder	排序	2	1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:12:53.089
4d1b76954df7d7fb217ddd7deba3f597	0	sys_depart	af598343d6bd897baa306c5489790bc7	departName	机构/部门名称	总经办	总经办1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:14:41.945
e3d484a81da3f2501ec99c1b3c2abe39	0	sys_depart	af598343d6bd897baa306c5489790bc7	departName	机构/部门名称	总经办1	总经办	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:14:46.841
ebc7a95d9edd094f2cd11a36776ecaa8	0	sys_depart	2756c6363bd77819291b0e003c019dd1	departOrder	排序	0	1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:02.14
e22f0e84eb3a5749357ca07d2a74720c	0	sys_depart	bdd29ce3d7f07a087f73ee2aced413f2	departOrder	排序	1	2	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:02.146
0344bb61abcabca731cb567f21ab2bae	0	sys_depart	4c5e87295e51cacc865bf92accb55875	departOrder	排序	0	1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:02.146
3ac76936557ce6d5c933b6de156539fa	0	sys_depart	94d2d903b59374c16e5244fa9641d8cd	departOrder	排序	2	3	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:02.147
5f3411a5afdce32fe94ca8c746d216d9	0	sys_depart	da5ae3b0afa3a7685e2d62273306b665	departOrder	排序	3	4	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:02.148
77183de08257df9972c213049654d42d	0	sys_depart	af598343d6bd897baa306c5489790bc7	parentId	父机构ID		2756c6363bd77819291b0e003c019dd1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:02.149
c413f992722b5bdc5e2312292c1ceb21	0	sys_depart	af598343d6bd897baa306c5489790bc7	orgCode	机构编码（唯一性由联合键 (tenant_id, org_code) 保证）	GM_OFFICE	CAKJA01	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:02.149
ebf4aa32f782445de6ef0581fa0b99e5	0	sys_depart	7d1f963d67dfe200572b8a84f6f1afa7	departOrder	排序	0	1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:02.173
f8760af6c5d3fc10fb331dd5e61fdc5b	0	sys_depart	fad47f8b8a28490abed1f058bf24c164	departOrder	排序	1	2	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:02.198
b9d34ea08243530c6570f6d0be9dbcc6	0	sys_depart	2128fcf7ff6c60920e2294e2b009b5ab	departOrder	排序	3	2	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:04.69
aada83a8ba1d647fde3ad03719384dad	0	sys_depart	555f8f0307a3d92dfa3923b58889decb	departOrder	排序	4	3	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:04.692
a2b77788c3b04f9588c9659c61fd0a08	0	sys_depart	531503f12d9cdf729d9ce8ae535ca6ab	departOrder	排序	5	4	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:04.694
3cd11c3dfa24d2cf3b00498a29228ef8	0	sys_depart	1577baeb20661e0ba522c60351c101b2	departOrder	排序	6	5	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:04.695
812f4e33cc55df632e479c08ac9bc035	0	sys_depart	d3e1489934c2d5d5cf10e4cd614c4404	departOrder	排序	7	6	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:04.702
11d749cdddcda745de1ba54de6246778	0	sys_depart	064719832c25df4ba5f58bfbf8872284	parentId	父机构ID		2756c6363bd77819291b0e003c019dd1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:04.708
e42344af87f3590da503b0f888f901fe	0	sys_depart	064719832c25df4ba5f58bfbf8872284	orgCode	机构编码（唯一性由联合键 (tenant_id, org_code) 保证）	HR	CAKJA02	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:04.708
40aa199d45da2ec0473e5cb3ad4183d9	0	sys_depart	5db52b767a1cbd831537d81976df3a95	departOrder	排序	8	7	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:04.726
8964e54b302d9f9ef31cb92f31208fd1	0	sys_depart	6cae4d898c1073b39b0b0ddd5364c928	departOrder	排序	9	8	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:04.75
dca29836d7d23f8d18f4f72c227e285c	0	sys_depart	f026194db425743c7cd02d3ed50deb67	departOrder	排序	10	9	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:04.775
9cd96c71f3cb33cdd33d1ab92f9ca484	0	sys_depart	fd6753b0084a2074f64f6c3bab3ff032	departOrder	排序	11	10	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:04.797
94b2420bc81360a962725cc61a6d22da	0	sys_depart	555f8f0307a3d92dfa3923b58889decb	departOrder	排序	3	2	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:06.689
13cfa7023a8346d058b0b3c4036da6a1	0	sys_depart	531503f12d9cdf729d9ce8ae535ca6ab	departOrder	排序	4	3	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:06.691
0a515557f945138719af4220ca1cb086	0	sys_depart	1577baeb20661e0ba522c60351c101b2	departOrder	排序	5	4	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:06.692
827c6fd0dadf3def463147fc3a992141	0	sys_depart	d3e1489934c2d5d5cf10e4cd614c4404	departOrder	排序	6	5	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:06.693
5ffea206482da632fdf455497f1b729f	0	sys_depart	5db52b767a1cbd831537d81976df3a95	departOrder	排序	7	6	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:06.694
2dc24f67ea78c45bbc7c3a6beef38bfa	0	sys_depart	2128fcf7ff6c60920e2294e2b009b5ab	parentId	父机构ID		2756c6363bd77819291b0e003c019dd1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:06.699
e9b8f5f12560913ddc7c1de09e69a405	0	sys_depart	2128fcf7ff6c60920e2294e2b009b5ab	departOrder	排序	2	3	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:06.699
436ff5875129aa15c733b3df685cd01a	0	sys_depart	2128fcf7ff6c60920e2294e2b009b5ab	orgCode	机构编码（唯一性由联合键 (tenant_id, org_code) 保证）	ADM	CAKJA03	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:06.699
85e05af39f4e37b9c06a967d6d28b37b	0	sys_depart	6cae4d898c1073b39b0b0ddd5364c928	departOrder	排序	8	7	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:06.716
67d4c205de9664e15216c4ed08b3e3e8	0	sys_depart	f026194db425743c7cd02d3ed50deb67	departOrder	排序	9	8	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:06.74
e88863ca0294761cc1b19515142f2adc	0	sys_depart	fd6753b0084a2074f64f6c3bab3ff032	departOrder	排序	10	9	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:06.762
e18b962cc3eb06ab4fd804d66c74d99e	0	sys_depart	d3e1489934c2d5d5cf10e4cd614c4404	departOrder	排序	5	4	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:08.289
ef773d80bdca2fd5b9083950564646d4	0	sys_depart	531503f12d9cdf729d9ce8ae535ca6ab	departOrder	排序	3	2	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:08.29
a2fcfa693918250c0aee188e942ee6ae	0	sys_depart	1577baeb20661e0ba522c60351c101b2	departOrder	排序	4	3	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:08.291
8cbc7504a1b4a46cd317109d89ef7670	0	sys_depart	5db52b767a1cbd831537d81976df3a95	departOrder	排序	6	5	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:08.293
12e1752e5602f8edb4eec803b4c89de3	0	sys_depart	f026194db425743c7cd02d3ed50deb67	departOrder	排序	7	6	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:10.248
267ada7a9383a0e46f5c411645545c05	0	sys_depart	531503f12d9cdf729d9ce8ae535ca6ab	parentId	父机构ID		2756c6363bd77819291b0e003c019dd1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:10.254
4b1db3f8423ef04a1012e3572791b053	0	sys_depart	531503f12d9cdf729d9ce8ae535ca6ab	departOrder	排序	2	5	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:10.254
8c8fd4a91827d58b3d7496e1f9abc190	0	sys_depart	531503f12d9cdf729d9ce8ae535ca6ab	orgCode	机构编码（唯一性由联合键 (tenant_id, org_code) 保证）	LEGAL	CAKJA05	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:10.254
08b422b11cb71ad556789c085a6ac09f	0	sys_depart	fd6753b0084a2074f64f6c3bab3ff032	departOrder	排序	8	7	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:10.271
216639cb54f081925b99bcb4084235e0	0	sys_depart	6cae4d898c1073b39b0b0ddd5364c928	departOrder	排序	7	6	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:08.296
6135d9caf6081ac25f8b701eea68abde	0	sys_depart	555f8f0307a3d92dfa3923b58889decb	parentId	父机构ID		2756c6363bd77819291b0e003c019dd1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:08.302
9711f865a02b079e28ccbe0b5f14cb4c	0	sys_depart	555f8f0307a3d92dfa3923b58889decb	departOrder	排序	2	4	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:08.302
a1e9148337a85c66a4d381ae9e6d5959	0	sys_depart	555f8f0307a3d92dfa3923b58889decb	orgCode	机构编码（唯一性由联合键 (tenant_id, org_code) 保证）	FIN	CAKJA04	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:08.302
681788dcb6bce156f7b50896e4287ca9	0	sys_depart	f026194db425743c7cd02d3ed50deb67	departOrder	排序	8	7	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:08.318
22fc7697927c6a067f31120e76e2fb63	0	sys_depart	fd6753b0084a2074f64f6c3bab3ff032	departOrder	排序	9	8	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:08.333
fc20913d7d1fbbe74128a7d18c24ade4	0	sys_depart	1577baeb20661e0ba522c60351c101b2	departOrder	排序	3	2	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:10.245
16921ab85f71d727caf00c70003133c0	0	sys_depart	fd6753b0084a2074f64f6c3bab3ff032	departOrder	排序	7	6	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:11.73
a7917789422e9012b7b0e949398d8bfb	0	sys_depart	6cae4d898c1073b39b0b0ddd5364c928	departOrder	排序	6	5	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:10.246
7c8ddab5c7538424cea4bfcc76a2d4a0	0	sys_depart	d3e1489934c2d5d5cf10e4cd614c4404	departOrder	排序	3	2	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:11.727
b86bfa3ff905250e2f9e0853fd9aab91	0	sys_depart	d3e1489934c2d5d5cf10e4cd614c4404	departOrder	排序	4	3	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:10.246
7777e20ce31cc9e672f6e4421273325e	0	sys_depart	5db52b767a1cbd831537d81976df3a95	departOrder	排序	5	4	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:10.247
27d27f078f26b3b2261fe8ae9fe9b182	0	sys_depart	5db52b767a1cbd831537d81976df3a95	departOrder	排序	4	3	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:11.731
d0f6a3b188e8877d452eea2e5d966b12	0	sys_depart	f026194db425743c7cd02d3ed50deb67	departOrder	排序	6	5	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:11.732
e39e5278a4f5b7b9edce402c6ae09f6d	0	sys_depart	6cae4d898c1073b39b0b0ddd5364c928	departOrder	排序	5	4	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:11.733
21d5300b6d12afb52a3160f14911bdfc	0	sys_depart	1577baeb20661e0ba522c60351c101b2	parentId	父机构ID		2756c6363bd77819291b0e003c019dd1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:11.742
d0e72ae3f6cd6dd65c43c57b9c8cfa2b	0	sys_depart	1577baeb20661e0ba522c60351c101b2	departOrder	排序	2	6	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:11.742
4069718481a5677229738bae2759a473	0	sys_depart	1577baeb20661e0ba522c60351c101b2	orgCode	机构编码（唯一性由联合键 (tenant_id, org_code) 保证）	PROD	CAKJA06	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:11.742
5714bb2fb2541e847c6b3b387f38de12	0	sys_depart	6cae4d898c1073b39b0b0ddd5364c928	departOrder	排序	4	3	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:13.566
66d7ddee6ae9b81b6faf6f52d4c7d882	0	sys_depart	5db52b767a1cbd831537d81976df3a95	departOrder	排序	3	2	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:13.567
382e3d16bf7cb13b1be840ed1b8a403f	0	sys_depart	fd6753b0084a2074f64f6c3bab3ff032	departOrder	排序	6	5	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:13.569
7debfce06a90e3a65f13244346cf2709	0	sys_depart	f026194db425743c7cd02d3ed50deb67	departOrder	排序	5	4	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:13.571
d79fb08c16eeb8e224a16e17e3768a5c	0	sys_depart	d3e1489934c2d5d5cf10e4cd614c4404	parentId	父机构ID		2756c6363bd77819291b0e003c019dd1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:13.574
7b6a194b9b8b4530cb2c7d69f109a615	0	sys_depart	d3e1489934c2d5d5cf10e4cd614c4404	departOrder	排序	2	7	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:13.574
07c2712d064bf7c5fb202f5604b94fab	0	sys_depart	d3e1489934c2d5d5cf10e4cd614c4404	orgCode	机构编码（唯一性由联合键 (tenant_id, org_code) 保证）	TECH	CAKJA07	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:13.574
a20096c7fed461d3a807ec50dac07483	0	sys_depart	f026194db425743c7cd02d3ed50deb67	departOrder	排序	4	3	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:15.488
f5191e0336f0b5cd5caffa810b6274d3	0	sys_depart	fd6753b0084a2074f64f6c3bab3ff032	departOrder	排序	5	4	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:15.492
eb46261c212e60ad4eda1af4c5b3d4e4	0	sys_depart	6cae4d898c1073b39b0b0ddd5364c928	departOrder	排序	3	2	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:15.493
eb4901ded8306b47d64ced188ab76409	0	sys_depart	5db52b767a1cbd831537d81976df3a95	parentId	父机构ID		2756c6363bd77819291b0e003c019dd1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:15.504
fc9aa358a40bc8eb4fed0d4dc8335a3a	0	sys_depart	5db52b767a1cbd831537d81976df3a95	departOrder	排序	2	8	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:15.504
96ebb5b4ca28e75d90cd744d96d4a96e	0	sys_depart	5db52b767a1cbd831537d81976df3a95	orgCode	机构编码（唯一性由联合键 (tenant_id, org_code) 保证）	MKT	CAKJA08	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:15.504
2ab351ab7fb9f0f2b17050e1f5a04686	0	sys_depart	f026194db425743c7cd02d3ed50deb67	departOrder	排序	3	2	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:17.199
c0fe8762819dcc00d487b1048cb555e1	0	sys_depart	fd6753b0084a2074f64f6c3bab3ff032	departOrder	排序	4	3	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:17.2
6417093aabaca24a48809481f1870003	0	sys_depart	6cae4d898c1073b39b0b0ddd5364c928	parentId	父机构ID		2756c6363bd77819291b0e003c019dd1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:17.205
9113377587af0d94bd5798dc26c026f6	0	sys_depart	6cae4d898c1073b39b0b0ddd5364c928	departOrder	排序	2	9	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:17.205
a2163397ef34f39b5f59a15fedec03f7	0	sys_depart	6cae4d898c1073b39b0b0ddd5364c928	orgCode	机构编码（唯一性由联合键 (tenant_id, org_code) 保证）	SALES	CAKJA09	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:17.205
b2f6d7bf8eb7ef17a626533abcdb68df	0	sys_depart	fd6753b0084a2074f64f6c3bab3ff032	departOrder	排序	3	2	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:19.257
750fec680e2680e960a7fcd6d0b46eae	0	sys_depart	f026194db425743c7cd02d3ed50deb67	parentId	父机构ID		2756c6363bd77819291b0e003c019dd1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:19.262
99051ded9a5544d99dbb1e2054df567d	0	sys_depart	f026194db425743c7cd02d3ed50deb67	departOrder	排序	2	10	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:19.262
8356ca0ab357ecd7ff5ce00fe447b458	0	sys_depart	f026194db425743c7cd02d3ed50deb67	orgCode	机构编码（唯一性由联合键 (tenant_id, org_code) 保证）	OPS	CAKJA10	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:19.262
4694f0196126b49ed862bfd80e382558	0	sys_depart	fd6753b0084a2074f64f6c3bab3ff032	parentId	父机构ID		2756c6363bd77819291b0e003c019dd1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:21.428
f22b62662ab70e49cc61909cf4abae3d	0	sys_depart	fd6753b0084a2074f64f6c3bab3ff032	departOrder	排序	2	11	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:21.428
487efa73674ace5fa0259c47ca4e00f1	0	sys_depart	fd6753b0084a2074f64f6c3bab3ff032	orgCode	机构编码（唯一性由联合键 (tenant_id, org_code) 保证）	CS	CAKJA11	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:21.428
4ce3cea64359e360fbe2cc6f6c2c508a	0	sys_depart	2756c6363bd77819291b0e003c019dd1	departName	机构/部门名称	ConciseAdmin科技	ConciseAdmin科技1	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:29.391
980e12c40e0dd3960efea9e0a186e2e2	0	sys_depart	2756c6363bd77819291b0e003c019dd1	departName	机构/部门名称	ConciseAdmin科技1	ConciseAdmin科技	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:41.297
390ddbf4f5da4e5ec5499d31548f855d	0	sys_depart	2756c6363bd77819291b0e003c019dd1	departOrder	排序	1	0	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:30:41.297
7b3aa318a24da7393295b34ffbea33f8	0	sys_depart	af598343d6bd897baa306c5489790bc7	orgCode	机构编码（唯一性由联合键 (tenant_id, org_code) 保证）	CAKJA01	GM	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:33:17.348
4e17b9556619699a53720077b7659f41	0	sys_depart	064719832c25df4ba5f58bfbf8872284	orgCode	机构编码（唯一性由联合键 (tenant_id, org_code) 保证）	CAKJA02	HR	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:33:30.856
1481202568f3d00258a5785d7380d1db	0	sys_depart	2128fcf7ff6c60920e2294e2b009b5ab	orgCode	机构编码（唯一性由联合键 (tenant_id, org_code) 保证）	CAKJA03	AMD	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:33:42.759
2bcb2c08645cbdfc8b22853a5a34ee15	0	sys_depart	555f8f0307a3d92dfa3923b58889decb	orgCode	机构编码（唯一性由联合键 (tenant_id, org_code) 保证）	CAKJA04	FIN	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:34:00.834
18dde622b782ce907ca10a9853a5dbe6	0	sys_depart	531503f12d9cdf729d9ce8ae535ca6ab	orgCode	机构编码（唯一性由联合键 (tenant_id, org_code) 保证）	CAKJA05	LEGAL	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:34:15.581
1dad990b61b6ad7bff2faf8ce53d0f67	0	sys_depart	1577baeb20661e0ba522c60351c101b2	orgCode	机构编码（唯一性由联合键 (tenant_id, org_code) 保证）	CAKJA06	PROD	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:34:29.167
3a45a54a3a771649b1e2f6903c0d8d10	0	sys_depart	d3e1489934c2d5d5cf10e4cd614c4404	orgCode	机构编码（唯一性由联合键 (tenant_id, org_code) 保证）	CAKJA07	TECH	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:34:45.225
4e5cf259e90d2c3ff1e83e3bda048bd0	0	sys_depart	5db52b767a1cbd831537d81976df3a95	orgCode	机构编码（唯一性由联合键 (tenant_id, org_code) 保证）	CAKJA08	MKT	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:35:01.469
a21b9534bce68f53f1715417a4450f2c	0	sys_depart	6cae4d898c1073b39b0b0ddd5364c928	orgCode	机构编码（唯一性由联合键 (tenant_id, org_code) 保证）	CAKJA09	SALES	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:35:19.191
7f128143cc302b78020021cd384a8738	0	sys_depart	f026194db425743c7cd02d3ed50deb67	orgCode	机构编码（唯一性由联合键 (tenant_id, org_code) 保证）	CAKJA10	OPS	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:35:39.765
a4bccc13ec2ec4b2874e9334b25c0342	0	sys_depart	fd6753b0084a2074f64f6c3bab3ff032	orgCode	机构编码（唯一性由联合键 (tenant_id, org_code) 保证）	CAKJA11	CS	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:35:49.493
17b483327591ceaaeea307d153525f8e	0	sys_depart	2756c6363bd77819291b0e003c019dd1	description	描述		总公司	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:36:04.14
9b591b11b3580c47c6affe298601c8a6	0	sys_depart	2756c6363bd77819291b0e003c019dd1	departName	机构/部门名称	ConciseAdmin科技	CA科技	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:36:15.284
ec5e7e97d2b4bff413e72f5dda1411a5	0	sys_depart	2756c6363bd77819291b0e003c019dd1	departName	机构/部门名称	CA科技	CAd科技	e9ca23d68d884d4ebb19d07889727dae	2026-11-25 18:36:39.989
\.


--
-- Data for Name: sys_message; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_message (id, title, content, msg_type, sender_id, tenant_id, receiver_count, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sys_message_user; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_message_user (id, message_id, user_id, is_read, read_at, created_at) FROM stdin;
\.


--
-- Data for Name: sys_permission; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_permission (id, parent_id, name, url, component, is_route, component_name, redirect, menu_type, perms, scope, perms_type, sort_no, always_show, icon, is_leaf, keep_alive, hidden, hide_tab, description, create_by, create_time, update_by, update_time, del_flag, rule_flag, status, internal_or_external) FROM stdin;
2e9a47cda433ced772aa8ed144ff92rd	2e9a47cda433ced772aa8ed144ff2d21	查询（改名）	\N	\N	1	\N	\N	2	/smoke/perm-node:list	tenant	1	1	\N	\N	\N	\N	0	\N	\N	\N	2026-11-10 13:06:07	\N	2026-11-10 13:06:07	1	0	1	\N
2e9a47cda433ced772aa8ed144ff92rf	2e9a47cda433ced772aa8ed144ff2d21	添加	\N	\N	1	\N	\N	2	/smoke/perm-node:add	tenant	1	2	\N	\N	\N	\N	0	\N	\N	\N	2026-11-10 13:06:07	\N	2026-11-10 13:06:07	1	0	1	\N
2e9a47cda433ced772aa8ed144ff92s4	2e9a47cda433ced772aa8ed144ff2d21	删除	\N	\N	1	\N	\N	2	/smoke/perm-node:delete	tenant	1	3	\N	\N	\N	\N	0	\N	\N	\N	2026-11-10 13:06:07	\N	2026-11-10 13:06:07	1	0	1	\N
985ad4f5465b3abcb74a314b964cbwth	985ad4f5465b3abcb74a314b964cfee9	查询（改名）	\N	\N	1	\N	\N	2	/smoke/perm-node:list	tenant	1	1	\N	\N	\N	\N	0	\N	\N	\N	2026-11-11 00:20:10	\N	2026-11-11 00:20:10	1	0	1	\N
985ad4f5465b3abcb74a314b964cbwtl	985ad4f5465b3abcb74a314b964cfee9	添加	\N	\N	1	\N	\N	2	/smoke/perm-node:add	tenant	1	2	\N	\N	\N	\N	0	\N	\N	\N	2026-11-11 00:20:10	\N	2026-11-11 00:20:10	1	0	1	\N
985ad4f5465b3abcb74a314b964cbwv3	985ad4f5465b3abcb74a314b964cfee9	删除	\N	\N	1	\N	\N	2	/smoke/perm-node:delete	tenant	1	3	\N	\N	\N	\N	0	\N	\N	\N	2026-11-11 00:20:10	\N	2026-11-11 00:20:10	1	0	1	\N
a5ddc7bb1daf775fd988f310c31dnthj	a5ddc7bb1daf775fd988f310c31d89fc	查询（改名）	\N	\N	1	\N	\N	2	/smoke/perm-node:list	tenant	1	1	\N	\N	\N	\N	0	\N	\N	\N	2026-11-07 16:14:32	\N	2026-11-07 16:14:32	1	0	1	\N
a5ddc7bb1daf775fd988f310c31dnthm	a5ddc7bb1daf775fd988f310c31d89fc	添加	\N	\N	1	\N	\N	2	/smoke/perm-node:add	tenant	1	2	\N	\N	\N	\N	0	\N	\N	\N	2026-11-07 16:14:32	\N	2026-11-07 16:14:32	1	0	1	\N
a5ddc7bb1daf775fd988f310c31dnti9	a5ddc7bb1daf775fd988f310c31d89fc	删除	\N	\N	1	\N	\N	2	/smoke/perm-node:delete	tenant	1	3	\N	\N	\N	\N	0	\N	\N	\N	2026-11-07 16:14:32	\N	2026-11-07 16:14:32	1	0	1	\N
dc1c54fcfd782021a12df8c0c680ayat	dc1c54fcfd782021a12df8c0c68046d3	查询（改名）	\N	\N	1	\N	\N	2	/smoke/perm-node:list	tenant	1	1	\N	\N	\N	\N	0	\N	\N	\N	2026-11-17 19:09:11	\N	2026-11-17 19:09:11	1	0	1	\N
dc1c54fcfd782021a12df8c0c680ayav	dc1c54fcfd782021a12df8c0c68046d3	添加	\N	\N	1	\N	\N	2	/smoke/perm-node:add	tenant	1	2	\N	\N	\N	\N	0	\N	\N	\N	2026-11-17 19:09:11	\N	2026-11-17 19:09:11	1	0	1	\N
dc1c54fcfd782021a12df8c0c680aybc	dc1c54fcfd782021a12df8c0c68046d3	删除	\N	\N	1	\N	\N	2	/smoke/perm-node:delete	tenant	1	3	\N	\N	\N	\N	0	\N	\N	\N	2026-11-17 19:09:11	\N	2026-11-17 19:09:11	1	0	1	\N
menu_1	\N	系统管理	/system	\N	1	\N	\N	0	\N	tenant	1	20	\N	Settings	0	0	0	\N	\N	admin	2026-11-04 03:32:30	admin	2026-11-09 13:32:51	0	0	1	\N
menu_10	menu_1	部门管理	/system/dept	system/dept/index	1	\N	\N	1	system:dept:list	tenant	1	4	\N	Building2	1	0	0	\N	\N	admin	2026-11-04 10:43:49	admin	2026-11-09 13:32:51	0	0	1	\N
menu_11	menu_10	部门新增	\N	\N	1	\N	\N	2	system:dept:add	tenant	1	1	\N	\N	1	0	0	\N	\N	admin	2026-11-04 10:43:49	admin	2026-11-04 10:43:49	0	0	1	\N
menu_12	menu_10	部门修改	\N	\N	1	\N	\N	2	system:dept:update	tenant	1	2	\N	\N	1	0	0	\N	\N	admin	2026-11-04 10:43:49	admin	2026-11-04 10:43:49	0	0	1	\N
menu_13	menu_10	部门删除	\N	\N	1	\N	\N	2	system:dept:delete	tenant	1	3	\N	\N	1	0	0	\N	\N	admin	2026-11-04 10:43:49	admin	2026-11-04 10:43:49	0	0	1	\N
menu_14	menu_data	数据字典	/system/dict	system/dict/index	1	\N	\N	1	system:dict:list	tenant	1	1	\N	Database	1	0	0	\N	\N	admin	2026-11-04 10:43:49	admin	2026-11-09 13:32:51	0	0	1	\N
menu_15	menu_14	字典新增	\N	\N	1	\N	\N	2	system:dict:add	tenant	1	1	\N	\N	1	0	0	\N	\N	admin	2026-11-04 10:43:49	admin	2026-11-04 10:43:49	0	0	1	\N
menu_16	menu_14	字典修改	\N	\N	1	\N	\N	2	system:dict:update	tenant	1	2	\N	\N	1	0	0	\N	\N	admin	2026-11-04 10:43:49	admin	2026-11-04 10:43:49	0	0	1	\N
menu_17	menu_14	字典删除	\N	\N	1	\N	\N	2	system:dict:delete	tenant	1	3	\N	\N	1	0	0	\N	\N	admin	2026-11-04 10:43:49	admin	2026-11-04 10:43:49	0	0	1	\N
menu_19	menu_audit	日志删除	\N	\N	1	\N	\N	2	system:log:delete	tenant	1	10	\N	\N	1	0	0	\N	\N	admin	2026-11-04 10:43:49	admin	2026-11-09 13:32:51	0	0	1	\N
menu_2	menu_1	用户管理	/system/users	system/user/index	1	\N	\N	1	system:user:list	tenant	1	1	\N	Users	1	0	0	\N	\N	admin	2026-11-04 03:32:30	admin	2026-11-09 13:32:51	0	0	1	\N
menu_20	menu_audit	日志导出	\N	\N	1	\N	\N	2	system:log:export	tenant	1	11	\N	\N	1	0	0	\N	\N	admin	2026-11-04 10:43:49	admin	2026-11-09 13:32:51	0	0	1	\N
menu_21	menu_collab	通知公告	/system/notice	system/notice/index	1	\N	\N	1	system:notice:list	tenant	1	1	\N	Megaphone	1	0	0	\N	\N	admin	2026-11-04 10:43:49	admin	2026-11-09 13:32:51	0	0	1	\N
menu_22	menu_21	公告查询	\N	\N	1	\N	\N	2	system:notice:list	tenant	1	1	\N	\N	1	0	0	\N	\N	admin	2026-11-04 10:43:49	admin	2026-11-04 10:43:49	0	0	1	\N
menu_23	menu_21	公告新增	\N	\N	1	\N	\N	2	system:notice:add	tenant	1	2	\N	\N	1	0	0	\N	\N	admin	2026-11-04 10:43:49	admin	2026-11-04 10:43:49	0	0	1	\N
menu_24	menu_21	公告修改	\N	\N	1	\N	\N	2	system:notice:update	tenant	1	3	\N	\N	1	0	0	\N	\N	admin	2026-11-04 10:43:49	admin	2026-11-04 10:43:49	0	0	1	\N
menu_25	menu_21	公告发布	\N	\N	1	\N	\N	2	system:notice:publish	tenant	1	4	\N	\N	1	0	0	\N	\N	admin	2026-11-04 10:43:49	admin	2026-11-04 10:43:49	0	0	1	\N
menu_26	menu_21	公告删除	\N	\N	1	\N	\N	2	system:notice:delete	tenant	1	5	\N	\N	1	0	0	\N	\N	admin	2026-11-04 10:43:49	admin	2026-11-04 10:43:49	0	0	1	\N
menu_31	menu_data	文件管理	/system/file	tools/storage/index	1	\N	\N	1	system:file:list	tenant	1	3	\N	FolderOpen	1	0	0	\N	\N	admin	2026-11-04 11:20:06	admin	2026-11-09 13:32:51	0	0	1	\N
menu_35	\N	仪表盘	/dashboard	\N	1	\N	\N	0	\N	tenant	1	10	\N	LayoutDashboard	1	\N	0	\N	\N	seed	2026-11-04 15:45:11	\N	2026-11-10 16:05:20	0	0	1	0
menu_35_dashboardlistne3c	menu_35	查询	\N	\N	1	\N	\N	2	dashboard:list	tenant	1	1	\N	\N	\N	\N	0	\N	\N	\N	2026-11-10 16:05:13	\N	2026-11-10 16:05:20	1	0	1	\N
menu_38	\N	运维管理	/ops	\N	1	\N	\N	0	\N	platform	1	40	\N	Server	0	\N	0	\N	\N	seed	2026-11-04 15:45:11	\N	2026-11-09 13:32:51	0	0	1	\N
menu_39	menu_1	菜单管理	/system/menu	\N	1	\N	\N	1	system:menu:list	platform	1	3	\N	ListTree	1	\N	0	\N	\N	seed	2026-11-04 15:45:11	\N	2026-11-09 13:32:51	0	0	1	\N
menu_40	menu_1	角色权限	/system/role	\N	1	\N	\N	1	system:role:list	tenant	1	2	\N	ShieldCheck	1	\N	0	\N	\N	seed	2026-11-04 15:45:11	\N	2026-11-09 13:32:51	0	0	1	\N
menu_41	menu_collab	日历管理	/system/calendar	\N	1	\N	\N	1	\N	tenant	1	2	\N	CalendarDays	1	\N	0	\N	\N	seed	2026-11-04 15:45:11	\N	2026-11-09 13:32:51	0	0	1	\N
menu_42	menu_1	职级管理	/system/level	\N	1	\N	\N	1	system:level:list	tenant	1	6	\N	Medal	1	\N	0	\N	\N	seed	2026-11-04 15:45:11	\N	2026-11-09 13:32:51	0	0	1	\N
menu_43	menu_1	岗位管理	/system/post	\N	1	\N	\N	1	system:post:list	tenant	1	5	\N	Briefcase	1	\N	0	\N	\N	seed	2026-11-04 15:45:11	\N	2026-11-09 13:32:51	0	0	1	\N
menu_44	menu_1	租户管理	/system/tenant	\N	1	\N	\N	1	\N	platform	1	7	\N	Network	1	\N	0	\N	\N	seed	2026-11-04 15:45:11	\N	2026-11-09 13:32:51	0	0	1	\N
menu_45	menu_data	行政区划	/system/region	\N	1	\N	\N	1	system:region:list	tenant	1	2	\N	MapPin	1	\N	0	\N	\N	seed	2026-11-04 15:45:11	\N	2026-11-09 13:32:51	0	0	1	\N
menu_46	menu_audit	登录日志	/system/log/login	\N	1	\N	\N	1	system:log:login	tenant	1	1	\N	LogIn	1	\N	0	\N	\N	seed	2026-11-04 15:45:11	\N	2026-11-09 13:32:51	0	0	1	\N
menu_47	menu_audit	操作日志	/system/log/operation	\N	1	\N	\N	1	system:log:oper	tenant	1	2	\N	FileText	1	\N	0	\N	\N	seed	2026-11-04 15:45:11	\N	2026-11-09 13:32:51	0	0	1	\N
menu_48	menu_38	定时任务	/ops/job	\N	1	\N	\N	1	system:job:list	platform	1	1	\N	Timer	1	\N	0	\N	\N	seed	2026-11-04 15:45:11	\N	2026-11-09 13:32:51	0	0	1	\N
menu_49	menu_38	在线用户	/ops/online	\N	1	\N	\N	1	system:online:list	platform	1	2	\N	UserCheck	1	\N	0	\N	\N	seed	2026-11-04 15:45:11	\N	2026-11-09 13:32:51	0	0	1	\N
menu_50	menu_38	服务监控	/ops/server	\N	1	\N	\N	1	system:monitor:server	platform	1	3	\N	Activity	1	\N	0	\N	\N	seed	2026-11-04 15:45:11	\N	2026-11-09 13:32:51	0	0	1	\N
menu_51	menu_38	缓存监控	/ops/cache	\N	1	\N	\N	1	system:monitor:cache	platform	1	4	\N	Package	1	\N	0	\N	\N	seed	2026-11-04 15:45:11	\N	2026-11-09 13:32:51	0	0	1	\N
menu_52	menu_40	角色新增	\N	\N	1	\N	\N	2	system:role:add	tenant	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-04 17:14:45	\N	2026-11-07 11:11:18	0	0	1	\N
menu_53	menu_40	角色修改	\N	\N	1	\N	\N	2	system:role:update	tenant	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-04 17:14:45	\N	2026-11-07 11:11:18	0	0	1	\N
menu_54	menu_40	角色删除	\N	\N	1	\N	\N	2	system:role:delete	tenant	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-04 17:14:45	\N	2026-11-07 11:11:18	0	0	1	\N
menu_55	menu_42	职级新增	\N	\N	1	\N	\N	2	system:level:add	tenant	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-04 17:47:02	\N	2026-11-07 11:11:18	0	0	1	\N
menu_56	menu_42	职级修改	\N	\N	1	\N	\N	2	system:level:update	tenant	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-04 17:47:02	\N	2026-11-07 11:11:18	0	0	1	\N
menu_57	menu_42	职级删除	\N	\N	1	\N	\N	2	system:level:delete	tenant	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-04 17:47:02	\N	2026-11-07 11:11:18	0	0	1	\N
menu_58	menu_43	岗位新增	\N	\N	1	\N	\N	2	system:post:add	tenant	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-04 17:47:02	\N	2026-11-07 11:11:18	0	0	1	\N
menu_59	menu_43	岗位修改	\N	\N	1	\N	\N	2	system:post:update	tenant	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-04 17:47:02	\N	2026-11-07 11:11:18	0	0	1	\N
menu_60	menu_43	岗位删除	\N	\N	1	\N	\N	2	system:post:delete	tenant	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-04 17:47:02	\N	2026-11-07 11:11:18	0	0	1	\N
menu_61	menu_48	任务新增	\N	\N	1	\N	\N	2	system:job:add	platform	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-04 18:54:10	\N	2026-11-07 11:11:18	0	0	1	\N
menu_62	menu_48	任务修改	\N	\N	1	\N	\N	2	system:job:update	platform	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-04 18:54:10	\N	2026-11-07 11:11:18	0	0	1	\N
menu_63	menu_48	任务删除	\N	\N	1	\N	\N	2	system:job:delete	platform	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-04 18:54:10	\N	2026-11-07 11:11:18	0	0	1	\N
menu_64	menu_48	任务执行	\N	\N	1	\N	\N	2	system:job:run	platform	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-04 18:54:10	\N	2026-11-07 11:11:18	0	0	1	\N
menu_65	menu_49	强制下线	\N	\N	1	\N	\N	2	system:online:kick	platform	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-04 18:54:10	\N	2026-11-07 11:11:18	0	0	1	\N
menu_66	menu_51	清理缓存	\N	\N	1	\N	\N	2	system:monitor:cache:clear	platform	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-04 18:54:10	\N	2026-11-07 11:11:18	0	0	1	\N
menu_67	menu_40	角色导出	\N	\N	1	\N	\N	2	system:role:export	tenant	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-04 19:39:46	\N	2026-11-07 11:11:18	0	0	1	\N
menu_68	menu_40	角色导入	\N	\N	1	\N	\N	2	system:role:import	tenant	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-04 19:39:46	\N	2026-11-07 11:11:18	0	0	1	\N
menu_69	menu_39	菜单新增	\N	\N	1	\N	\N	2	system:menu:add	platform	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-05 10:36:21	\N	2026-11-07 11:11:18	0	0	1	\N
menu_7	menu_2	用户新增	\N	\N	1	\N	\N	2	system:user:add	tenant	1	1	\N	\N	1	0	0	\N	\N	admin	2026-11-04 10:43:49	admin	2026-11-04 10:43:49	0	0	1	\N
menu_70	menu_39	菜单修改	\N	\N	1	\N	\N	2	system:menu:update	platform	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-05 10:36:21	\N	2026-11-07 11:11:18	0	0	1	\N
menu_71	menu_39	菜单删除	\N	\N	1	\N	\N	2	system:menu:delete	platform	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-05 10:36:21	\N	2026-11-07 11:11:18	0	0	1	\N
menu_75	menu_2	用户导出	\N	\N	1	\N	\N	2	system:user:export	tenant	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-05 19:03:18	\N	2026-11-07 11:11:18	0	0	1	\N
menu_76	menu_2	用户导入	\N	\N	1	\N	\N	2	system:user:import	tenant	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-05 19:03:18	\N	2026-11-07 11:11:18	0	0	1	\N
menu_77	menu_audit	日志导入	\N	\N	1	\N	\N	2	system:log:import	tenant	1	12	\N	\N	1	0	0	0	\N	\N	2026-11-06 19:59:09	\N	2026-11-09 13:32:51	0	0	1	\N
menu_78	menu_21	公告导入	\N	\N	1	\N	\N	2	system:notice:import	tenant	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-07 11:10:34	\N	2026-11-07 11:11:18	0	0	1	\N
menu_79	menu_42	职级导出	\N	\N	1	\N	\N	2	system:level:export	tenant	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-07 11:10:34	\N	2026-11-07 11:11:18	0	0	1	\N
menu_8	menu_2	用户修改	\N	\N	1	\N	\N	2	system:user:update	tenant	1	2	\N	\N	1	0	0	\N	\N	admin	2026-11-04 10:43:49	admin	2026-11-04 10:43:49	0	0	1	\N
menu_80	menu_42	职级导入	\N	\N	1	\N	\N	2	system:level:import	tenant	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-07 11:10:34	\N	2026-11-07 11:11:18	0	0	1	\N
menu_81	menu_43	岗位导出	\N	\N	1	\N	\N	2	system:post:export	tenant	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-07 11:10:34	\N	2026-11-07 11:11:18	0	0	1	\N
menu_82	menu_43	岗位导入	\N	\N	1	\N	\N	2	system:post:import	tenant	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-07 11:10:34	\N	2026-11-07 11:11:18	0	0	1	\N
menu_83	menu_14	字典导出	\N	\N	1	\N	\N	2	system:dict:export	tenant	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-07 11:10:34	\N	2026-11-07 11:11:18	0	0	1	\N
menu_84	menu_14	字典导入	\N	\N	1	\N	\N	2	system:dict:import	tenant	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-07 11:10:34	\N	2026-11-07 11:11:18	0	0	1	\N
menu_85	menu_10	部门导出	\N	\N	1	\N	\N	2	system:dept:export	tenant	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-07 11:10:34	\N	2026-11-07 11:11:18	0	0	1	\N
menu_86	menu_39	菜单导出	\N	\N	1	\N	\N	2	system:menu:export	platform	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-07 11:10:34	\N	2026-11-07 11:11:18	0	0	1	\N
menu_87	menu_48	任务导出	\N	\N	1	\N	\N	2	system:job:export	platform	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-07 11:10:34	\N	2026-11-07 11:11:18	0	0	1	\N
menu_88	menu_31	文件上传	\N	\N	1	\N	\N	2	system:file:upload	tenant	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-07 11:10:34	\N	2026-11-07 11:11:18	0	0	1	\N
menu_89	menu_31	新建文件夹	\N	\N	1	\N	\N	2	system:file:add	tenant	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-07 11:10:34	\N	2026-11-07 11:11:18	0	0	1	\N
menu_9	menu_2	用户删除	\N	\N	1	\N	\N	2	system:user:delete	tenant	1	3	\N	\N	1	0	0	\N	\N	admin	2026-11-04 10:43:49	admin	2026-11-04 10:43:49	0	0	1	\N
menu_90	menu_31	文件修改	\N	\N	1	\N	\N	2	system:file:update	tenant	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-07 11:10:34	\N	2026-11-07 11:11:18	0	0	1	\N
menu_91	menu_31	文件删除	\N	\N	1	\N	\N	2	system:file:delete	tenant	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-07 11:10:34	\N	2026-11-07 11:11:18	0	0	1	\N
menu_92	menu_31	文件下载	\N	\N	1	\N	\N	2	system:file:download	tenant	1	\N	\N	\N	1	\N	0	\N	\N	seed	2026-11-07 11:10:34	\N	2026-11-07 11:11:18	0	0	1	\N
menu_93	menu_2	重置密码	\N	\N	1	\N	\N	2	system:user:reset-password	tenant	1	6	\N	\N	1	\N	0	\N	\N	\N	2026-11-09 13:32:51	\N	\N	0	0	1	\N
menu_94	menu_2	恢复用户	\N	\N	1	\N	\N	2	system:user:restore	tenant	1	7	\N	\N	1	\N	0	\N	\N	\N	2026-11-09 13:32:51	\N	\N	0	0	1	\N
menu_95	menu_1	水印策略	\N	\N	1	\N	\N	2	system:watermark:edit	tenant	1	8	\N	\N	1	\N	0	\N	\N	\N	2026-11-09 13:32:51	\N	\N	0	0	1	\N
menu_96	menu_45	区划新增	\N	\N	1	\N	\N	2	system:region:add	tenant	1	1	\N	\N	1	\N	0	\N	\N	\N	2026-11-09 13:32:51	\N	\N	0	0	1	\N
menu_97	menu_45	区划修改	\N	\N	1	\N	\N	2	system:region:update	tenant	1	2	\N	\N	1	\N	0	\N	\N	\N	2026-11-09 13:32:51	\N	\N	0	0	1	\N
menu_98	menu_45	区划删除	\N	\N	1	\N	\N	2	system:region:delete	tenant	1	3	\N	\N	1	\N	0	\N	\N	\N	2026-11-09 13:32:51	\N	\N	0	0	1	\N
menu_99	menu_45	区划导入	\N	\N	1	\N	\N	2	system:region:import	tenant	1	4	\N	\N	1	\N	0	\N	\N	\N	2026-11-09 13:32:51	\N	\N	0	0	1	\N
menu_audit	\N	安全审计	/audit	\N	1	\N	\N	0	\N	tenant	1	50	\N	ShieldCheck	0	\N	0	\N	\N	\N	2026-11-09 13:32:51	\N	\N	0	0	1	\N
menu_biz_order	menu_collab	订单管理	/system/biz_orders	\N	1	\N	\N	1	biz_order:list	tenant	0	50	\N	Briefcase	0	\N	0	\N	\N	\N	\N	\N	\N	0	1	1	\N
menu_biz_order_add	menu_biz_order	新增订单	\N	\N	1	\N	\N	2	biz_order:add	tenant	0	1	\N	\N	1	\N	0	\N	\N	\N	\N	\N	\N	0	1	1	\N
menu_biz_order_del	menu_biz_order	删除订单	\N	\N	1	\N	\N	2	biz_order:delete	tenant	0	3	\N	\N	1	\N	0	\N	\N	\N	\N	\N	\N	0	1	1	\N
menu_biz_order_edit	menu_biz_order	编辑订单	\N	\N	1	\N	\N	2	biz_order:update	tenant	0	2	\N	\N	1	\N	0	\N	\N	\N	\N	\N	\N	0	1	1	\N
menu_codegen	menu_1	代码生成	/system/codegen	\N	1	\N	\N	1	tools:codegen:list	platform	0	90	\N	Wrench	0	\N	0	\N	\N	\N	\N	\N	\N	0	1	1	\N
menu_codegen_generate	menu_codegen	执行生成	\N	\N	1	\N	\N	2	tools:codegen:generate	platform	0	1	\N	\N	1	\N	0	\N	\N	\N	\N	\N	\N	0	1	1	\N
menu_collab	\N	协同办公	/collab	\N	1	\N	\N	0	\N	tenant	1	60	\N	Handshake	0	\N	0	\N	\N	\N	2026-11-09 13:32:51	\N	\N	0	0	1	\N
menu_config	menu_1	参数配置	/system/config	\N	1	\N	\N	1	system:config:list	tenant	0	9	\N	Settings	0	\N	0	\N	\N	\N	\N	\N	\N	0	0	1	\N
menu_config_update	menu_config	修改参数	\N	\N	1	\N	\N	2	system:config:update	tenant	0	1	\N	\N	1	\N	0	\N	\N	\N	\N	\N	\N	0	0	1	\N
menu_customer	menu_collab	客户管理	/system/customers	\N	1	\N	\N	1	customer:list	tenant	0	50	\N	Briefcase	0	\N	0	\N	\N	\N	\N	\N	\N	0	1	1	\N
menu_customer_add	menu_customer	新增客户	\N	\N	1	\N	\N	2	customer:add	tenant	0	1	\N	\N	1	\N	0	\N	\N	\N	\N	\N	\N	0	1	1	\N
menu_customer_del	menu_customer	删除客户	\N	\N	1	\N	\N	2	customer:delete	tenant	0	3	\N	\N	1	\N	0	\N	\N	\N	\N	\N	\N	0	1	1	\N
menu_customer_edit	menu_customer	编辑客户	\N	\N	1	\N	\N	2	customer:update	tenant	0	2	\N	\N	1	\N	0	\N	\N	\N	\N	\N	\N	0	1	1	\N
menu_data	\N	数据管理	/data	\N	1	\N	\N	0	\N	tenant	1	30	\N	Database	0	\N	0	\N	\N	\N	2026-11-09 13:32:51	\N	\N	0	0	1	\N
menu_log_change	menu_audit	变更审计	/system/log/change	\N	1	\N	\N	1	system:log:change	tenant	0	3	\N	History	1	\N	0	\N	\N	\N	\N	\N	\N	0	0	1	\N
menu_msg	menu_collab	消息中心	/system/message	\N	1	\N	\N	1	system:message:list	tenant	0	3	\N	Mail	0	\N	0	\N	\N	\N	\N	\N	\N	0	0	1	\N
menu_msg_del	menu_msg	删除消息	\N	\N	1	\N	\N	2	system:message:delete	tenant	0	2	\N	\N	1	\N	0	\N	\N	\N	\N	\N	\N	0	0	1	\N
menu_msg_send	menu_msg	发送消息	\N	\N	1	\N	\N	2	system:message:send	tenant	0	1	\N	\N	1	\N	0	\N	\N	\N	\N	\N	\N	0	0	1	\N
menu_openapp	menu_1	开放平台	/system/app	\N	1	\N	\N	1	system:app:list	tenant	0	10	\N	Network	0	\N	0	\N	\N	\N	\N	\N	\N	0	0	1	\N
menu_openapp_create	menu_openapp	创建应用	\N	\N	1	\N	\N	2	system:app:create	tenant	0	1	\N	\N	1	\N	0	\N	\N	\N	\N	\N	\N	0	0	1	\N
menu_openapp_delete	menu_openapp	删除应用	\N	\N	1	\N	\N	2	system:app:delete	tenant	0	3	\N	\N	1	\N	0	\N	\N	\N	\N	\N	\N	0	0	1	\N
menu_openapp_reset	menu_openapp	重置密钥	\N	\N	1	\N	\N	2	system:app:reset	tenant	0	4	\N	\N	1	\N	0	\N	\N	\N	\N	\N	\N	0	0	1	\N
menu_openapp_update	menu_openapp	编辑应用	\N	\N	1	\N	\N	2	system:app:update	tenant	0	2	\N	\N	1	\N	0	\N	\N	\N	\N	\N	\N	0	0	1	\N
menu_supplier	menu_collab	供应商管理	/system/suppliers	\N	1	\N	\N	1	supplier:list	tenant	0	4	\N	Briefcase	0	\N	0	\N	\N	\N	\N	\N	\N	0	0	1	\N
menu_supplier_add	menu_supplier	新增供应商	\N	\N	1	\N	\N	2	supplier:add	tenant	0	1	\N	\N	1	\N	0	\N	\N	\N	\N	\N	\N	0	0	1	\N
menu_supplier_del	menu_supplier	删除供应商	\N	\N	1	\N	\N	2	supplier:delete	tenant	0	3	\N	\N	1	\N	0	\N	\N	\N	\N	\N	\N	0	0	1	\N
menu_supplier_edit	menu_supplier	编辑供应商	\N	\N	1	\N	\N	2	supplier:update	tenant	0	2	\N	\N	1	\N	0	\N	\N	\N	\N	\N	\N	0	0	1	\N
menu_task	menu_collab	任务管理	/system/task	system/task/index	1	\N	\N	1	system:task:list	tenant	1	5	\N	ListTodo	0	\N	0	\N	\N	\N	2026-11-09 15:56:13	\N	\N	0	0	1	\N
menu_task_add	menu_task	新增任务	\N	\N	1	\N	\N	2	system:task:add	tenant	1	1	\N	\N	1	\N	0	\N	\N	\N	2026-11-09 15:56:13	\N	\N	0	0	1	\N
menu_task_delete	menu_task	删除任务	\N	\N	1	\N	\N	2	system:task:delete	tenant	1	3	\N	\N	1	\N	0	\N	\N	\N	2026-11-09 15:56:13	\N	\N	0	0	1	\N
menu_task_update	menu_task	修改任务	\N	\N	1	\N	\N	2	system:task:update	tenant	1	2	\N	\N	1	\N	0	\N	\N	\N	2026-11-09 15:56:13	\N	\N	0	0	1	\N
menu_tnt_add	menu_44	新增租户	\N	\N	1	\N	\N	2	system:tenant:add	platform	1	2	\N	\N	\N	\N	0	\N	\N	\N	2026-11-07 13:19:13	\N	\N	0	0	1	\N
menu_tnt_del	menu_44	删除租户	\N	\N	1	\N	\N	2	system:tenant:delete	platform	1	4	\N	\N	\N	\N	0	\N	\N	\N	2026-11-07 13:19:13	\N	\N	0	0	1	\N
menu_tnt_edit	menu_44	编辑租户	\N	\N	1	\N	\N	2	system:tenant:edit	platform	1	3	\N	\N	\N	\N	0	\N	\N	\N	2026-11-07 13:19:13	\N	\N	0	0	1	\N
menu_tnt_list	menu_44	查询租户	\N	\N	1	\N	\N	2	system:tenant:list	platform	1	1	\N	\N	\N	\N	0	\N	\N	\N	2026-11-07 13:19:13	\N	\N	0	0	1	\N
menu_tnt_user	menu_44	分配用户	\N	\N	1	\N	\N	2	system:tenant:user	platform	1	5	\N	\N	\N	\N	0	\N	\N	\N	2026-11-07 13:19:13	\N	\N	0	0	1	\N
menu_user_platform	menu_2	平台管理员	\N	\N	1	\N	\N	2	system:user:platform	platform	1	8	\N	\N	1	\N	0	\N	\N	\N	2026-11-09 17:26:02	\N	\N	0	0	1	\N
menu_user_vip	menu_2	VIP 设置	\N	\N	1	\N	\N	2	system:user:vip	platform	1	9	\N	\N	1	\N	0	\N	\N	\N	2026-11-17 12:37:28	\N	\N	0	0	1	\N
menu_webhook_create	menu_openapp	创建订阅	\N	\N	1	\N	\N	2	system:webhook:create	tenant	0	5	\N	\N	1	\N	0	\N	\N	\N	\N	\N	\N	0	0	1	\N
menu_webhook_delete	menu_openapp	删除订阅	\N	\N	1	\N	\N	2	system:webhook:delete	tenant	0	7	\N	\N	1	\N	0	\N	\N	\N	\N	\N	\N	0	0	1	\N
menu_webhook_update	menu_openapp	编辑订阅	\N	\N	1	\N	\N	2	system:webhook:update	tenant	0	6	\N	\N	1	\N	0	\N	\N	\N	\N	\N	\N	0	0	1	\N
\.


--
-- Data for Name: sys_position; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_position (id, post_code, post_name, post_sort, dept_id, status, description, create_by, create_time, update_by, update_time, tenant_id) FROM stdin;
3e7ff770b6df3276a36d04bd5e60ae06	CEO	总经理	1	af598343d6bd897baa306c5489790bc7	1	总经办(GM)	admin	2026-11-26 00:31:43.008	\N	\N	0
\.


--
-- Data for Name: sys_position_role; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_position_role (id, position_id, role_id, tenant_id, create_time) FROM stdin;
\.


--
-- Data for Name: sys_quartz_job; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_quartz_job (id, job_class_name, cron_expression, parameter, description, tenant_id, status, del_flag, create_by, create_time, update_by, update_time) FROM stdin;
\.


--
-- Data for Name: sys_region; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_region (id, area_code, city_code, parent_code, zip_code, level, level_text, pid, name, short_name, full_name, pinyin, lng, lat, create_time, update_time) FROM stdin;
\.


--
-- Data for Name: sys_role; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_role (id, role_name, role_code, data_scope, description, status, create_by, create_time, update_by, update_time, tenant_id, is_builtin) FROM stdin;
4d4c8d42c168e1ce94b7d2b3c76422b1	普通员工（测试）	member_test	3	数据范围验证用	1	\N	2026-11-26 01:03:11.408504	\N	\N	0	0
6dbea13a8673eb60c17a59c8381bf368	只读员工（测试）	member_viewonly	3	只读验证用：可见菜单与数据，无新增/编辑/删除按钮权限	1	\N	2026-11-26 01:52:11.77129	\N	\N	0	0
\.


--
-- Data for Name: sys_role_permission; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_role_permission (role_id, permission_id, id, data_rule_ids, operate_date, operate_ip) FROM stdin;
4d4c8d42c168e1ce94b7d2b3c76422b1	menu_35	28e8bd7bb34043a2d09f3a8b27f4149f	\N	2026-11-26 01:21:25.857009	\N
4d4c8d42c168e1ce94b7d2b3c76422b1	menu_collab	18d210029cbc7cd338b855cddc11923e	\N	2026-11-26 01:21:25.857009	\N
4d4c8d42c168e1ce94b7d2b3c76422b1	menu_customer	1d2c3f2fd3d96c30a5cf5edc946f943e	\N	2026-11-26 01:21:25.857009	\N
4d4c8d42c168e1ce94b7d2b3c76422b1	menu_customer_add	27de99d1fdd844956f3dc9d37c7a8ae9	\N	2026-11-26 01:21:25.857009	\N
4d4c8d42c168e1ce94b7d2b3c76422b1	menu_customer_edit	2ad98d235e1ecba94fdb844e78cb9aec	\N	2026-11-26 01:21:25.857009	\N
4d4c8d42c168e1ce94b7d2b3c76422b1	menu_customer_del	6f89049bf4d0bccab6b18395f4162ed4	\N	2026-11-26 01:21:25.857009	\N
6dbea13a8673eb60c17a59c8381bf368	menu_35	de9a4d8bd59210268e083370bf8f36e3	\N	2026-11-26 01:52:11.77129	\N
6dbea13a8673eb60c17a59c8381bf368	menu_collab	d835713be0138de01f15597d39135250	\N	2026-11-26 01:52:11.77129	\N
6dbea13a8673eb60c17a59c8381bf368	menu_customer	a4901bbb319e4bf9c57d8b60b534987c	\N	2026-11-26 01:52:11.77129	\N
\.


--
-- Data for Name: sys_tenant; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_tenant (id, name, code, owner_user_id, contact, phone, plan, begin_date, expire_at, status, remark, del_flag, create_by, create_time, update_by, update_time) FROM stdin;
\.


--
-- Data for Name: sys_tenant_menu; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_tenant_menu (id, tenant_id, permission_id, create_time) FROM stdin;
\.


--
-- Data for Name: sys_tenant_usage; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_tenant_usage (id, tenant_id, metric, period, value, updated_at, created_at) FROM stdin;
\.


--
-- Data for Name: sys_user; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_user (id, username, realname, password, salt, avatar, birthday, bio, sex, email, phone, password_expire_at, must_change_password, totp_secret, totp_enabled, status, del_flag, is_platform_admin, is_tenant_admin, vip_level, vip_expire_at, work_no, telephone, create_by, create_time, update_by, update_time, org_code, depart_ids, level_id, third_id, third_type, activiti_sync, user_identity, client_id, login_tenant_id, bpm_status, sign_enable, sign, main_dep_post_id, position_type, last_pwd_update_time, sort, iz_hide_contact) FROM stdin;
e9ca23d68d884d4ebb19d07889727dae	admin	管理员	$argon2id$v=19$m=19456,t=2,p=1$Z5s1zknDj6wa2Dlad6Va7Q$Lrpf3QWdHaSMOeSf0qXp+LGElprgjGipZQvoQDQ45EA	\N		1986-02-01	\N	1	concise@163.com	18611111111	2027-02-15 11:24:13	0	\N	0	1	0	1	0	0	\N	\N	\N	\N	2019-06-21 17:54:10	admin	2026-11-17 11:24:13	\N	\N	\N	\N	\N	\N	2	\N	\N	0	\N	\N	\N	\N	2025-11-25 15:42:34	1000	\N
0c8c4eeb19abc6c501b59287ba5ae9e4	xiaowang	小王	$argon2id$v=19$m=19456,t=2,p=1$LcvmNaBHfkwx5YLEZco4JQ$VxtUKBffRT4VAcN01eRweFLwLRh/ag0BU5iV4oGQ7cU	ygIvyDe0	\N	\N	\N	\N	\N	\N	\N	0	\N	0	1	0	0	0	0	\N	\N	\N	\N	2026-11-26 01:03:11.42496	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
ca81b8e211353133e77bc75b49913d89	tech01	张技术	$argon2id$v=19$m=19456,t=2,p=1$LcvmNaBHfkwx5YLEZco4JQ$VxtUKBffRT4VAcN01eRweFLwLRh/ag0BU5iV4oGQ7cU	MxsEvQjM	\N	\N	\N	\N	\N	\N	\N	0	\N	0	1	0	0	0	0	\N	\N	\N	\N	2026-11-26 01:03:11.42496	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
41c5e48c0d6d1081bf9f4887f6d47606	fin01	李财务	$argon2id$v=19$m=19456,t=2,p=1$LcvmNaBHfkwx5YLEZco4JQ$VxtUKBffRT4VAcN01eRweFLwLRh/ag0BU5iV4oGQ7cU	dRmm85PR	\N	\N	\N	\N	\N	\N	\N	0	\N	0	1	0	0	0	0	\N	\N	\N	\N	2026-11-26 01:03:11.42496	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
0d290dddef2c688b263d34f1dbf3c801	cs01	王客服	$argon2id$v=19$m=19456,t=2,p=1$LcvmNaBHfkwx5YLEZco4JQ$VxtUKBffRT4VAcN01eRweFLwLRh/ag0BU5iV4oGQ7cU	e3bqfUL0	\N	\N	\N	\N	\N	\N	\N	0	\N	0	1	0	0	0	0	\N	\N	\N	\N	2026-11-26 01:03:11.42496	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
01bc4b87600d348e591cb18ba87dbcfc	mkt01	赵市场	$argon2id$v=19$m=19456,t=2,p=1$LcvmNaBHfkwx5YLEZco4JQ$VxtUKBffRT4VAcN01eRweFLwLRh/ag0BU5iV4oGQ7cU	ogEHB8WZ	\N	\N	\N	\N	\N	\N	\N	0	\N	0	1	0	0	0	0	\N	\N	\N	\N	2026-11-26 01:03:11.42496	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: sys_user_backup_code; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_user_backup_code (id, user_id, code_hash, used_at, created_at) FROM stdin;
\.


--
-- Data for Name: sys_user_depart; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_user_depart (user_id, dep_id, "ID") FROM stdin;
0c8c4eeb19abc6c501b59287ba5ae9e4	d3e1489934c2d5d5cf10e4cd614c4404	ce860230c933e76b52ff1bce6ecdc510
ca81b8e211353133e77bc75b49913d89	d03c1e5fa900c7cc374e215fc5aa03c4	5d48bf211b23274f83e25904b927582e
41c5e48c0d6d1081bf9f4887f6d47606	555f8f0307a3d92dfa3923b58889decb	9fcdf17787254cbe6bf9bad6932952af
0d290dddef2c688b263d34f1dbf3c801	fd6753b0084a2074f64f6c3bab3ff032	b1a33ba027ca1962d3630f07d82416a3
01bc4b87600d348e591cb18ba87dbcfc	5db52b767a1cbd831537d81976df3a95	d230b337604b0e995533fb5b6b470ac6
\.


--
-- Data for Name: sys_user_post; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_user_post (user_id, post_id) FROM stdin;
\.


--
-- Data for Name: sys_user_role; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_user_role (user_id, role_id, id, tenant_id, source) FROM stdin;
01bc4b87600d348e591cb18ba87dbcfc	4d4c8d42c168e1ce94b7d2b3c76422b1	dffc41aa02d91afbef8a1fb0a1ca9f89	0	manual
ca81b8e211353133e77bc75b49913d89	4d4c8d42c168e1ce94b7d2b3c76422b1	b1450575589d201eecc59dabe9c0245b	0	manual
41c5e48c0d6d1081bf9f4887f6d47606	4d4c8d42c168e1ce94b7d2b3c76422b1	170ff161703e1fa025c80d67f65378ba	0	manual
0d290dddef2c688b263d34f1dbf3c801	4d4c8d42c168e1ce94b7d2b3c76422b1	d70e7098e59e81c8dac0eb4d71084267	0	manual
0c8c4eeb19abc6c501b59287ba5ae9e4	6dbea13a8673eb60c17a59c8381bf368	9d1435e687c942c28d2ab60f85901742	0	manual
\.


--
-- Data for Name: sys_user_setting; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_user_setting (user_id, settings, update_time) FROM stdin;
\.


--
-- Data for Name: sys_user_supervise_dept; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_user_supervise_dept (id, user_id, dept_id, tenant_id, create_time) FROM stdin;
95931954279497f4ada8fcec0ba58577	0c8c4eeb19abc6c501b59287ba5ae9e4	d3e1489934c2d5d5cf10e4cd614c4404	0	2026-11-26 01:03:11.503
df9c60f45c6091369a0fa8abf3ee14fd	0c8c4eeb19abc6c501b59287ba5ae9e4	555f8f0307a3d92dfa3923b58889decb	0	2026-11-26 01:03:11.503
44be0a0203f6fad8222e6a68220b83ac	0c8c4eeb19abc6c501b59287ba5ae9e4	fd6753b0084a2074f64f6c3bab3ff032	0	2026-11-26 01:03:11.503
2c68fb7a20104158abcb2df11dee4857	0c8c4eeb19abc6c501b59287ba5ae9e4	d03c1e5fa900c7cc374e215fc5aa03c4	0	2026-11-26 01:03:11.503
09af6e3197a73b7ea13ea8dc33d9c706	0c8c4eeb19abc6c501b59287ba5ae9e4	b901fdcf1f05ef030a4d8611e34c8884	0	2026-11-26 01:03:11.503
d7841d30fbc9fc8b8d92906921154cda	0c8c4eeb19abc6c501b59287ba5ae9e4	0805397fc9ee27797f78e7f0e517fcdb	0	2026-11-26 01:03:11.503
c36229a932db9e7338cb21c26d137e7e	0c8c4eeb19abc6c501b59287ba5ae9e4	5be257cef78d16f621e7b86a0d646e0a	0	2026-11-26 01:03:11.503
06b69ca6d80ab694601e585e766b8502	0c8c4eeb19abc6c501b59287ba5ae9e4	1fb4b0372ab1925f031895b23f3440b4	0	2026-11-26 01:03:11.503
ab632e706bed0cf66eadefce81bce73b	0c8c4eeb19abc6c501b59287ba5ae9e4	8ccf8ae1828c7c9f9b9933ff3590f674	0	2026-11-26 01:03:11.503
eaed04bdfbc48b48c8912fb1351f2575	0c8c4eeb19abc6c501b59287ba5ae9e4	ec46d2554ec6745bd25c89eacbf2838f	0	2026-11-26 01:03:11.503
9ab6f309adbca151ff268eff85acfff3	0c8c4eeb19abc6c501b59287ba5ae9e4	e3c7a43c3bf49f56d6ab700e270e1114	0	2026-11-26 01:03:11.503
e67c6b7bfa59247d0ee10082cfe30115	0c8c4eeb19abc6c501b59287ba5ae9e4	7d1f963d67dfe200572b8a84f6f1afa7	0	2026-11-26 01:03:11.503
8d90f79e4c10ff15f8e553d4147b1453	0c8c4eeb19abc6c501b59287ba5ae9e4	fad47f8b8a28490abed1f058bf24c164	0	2026-11-26 01:03:11.503
e09a479894d2fccd0bdcea4510c7c674	ca81b8e211353133e77bc75b49913d89	d3e1489934c2d5d5cf10e4cd614c4404	0	2026-11-26 01:32:10.438
481b9023bccb112244bc013b4f87f9ef	ca81b8e211353133e77bc75b49913d89	d03c1e5fa900c7cc374e215fc5aa03c4	0	2026-11-26 01:32:10.438
ae27e5b5d0e4cd758bf408f95622c139	ca81b8e211353133e77bc75b49913d89	b901fdcf1f05ef030a4d8611e34c8884	0	2026-11-26 01:32:10.438
bc4a4a5bd6a91265f4a431a29046010e	ca81b8e211353133e77bc75b49913d89	0805397fc9ee27797f78e7f0e517fcdb	0	2026-11-26 01:32:10.438
038b1e410797b5e7874553165883fc52	ca81b8e211353133e77bc75b49913d89	5be257cef78d16f621e7b86a0d646e0a	0	2026-11-26 01:32:10.438
42d182f88c9007fe7d42c403b9e8b5e4	ca81b8e211353133e77bc75b49913d89	1fb4b0372ab1925f031895b23f3440b4	0	2026-11-26 01:32:10.438
6da614b11b3566fe34bc215ad5ac4d3c	41c5e48c0d6d1081bf9f4887f6d47606	555f8f0307a3d92dfa3923b58889decb	0	2026-11-26 01:32:10.438
46fac71151f7aa3b9c73d8856734f4d0	41c5e48c0d6d1081bf9f4887f6d47606	8ccf8ae1828c7c9f9b9933ff3590f674	0	2026-11-26 01:32:10.438
1d3845e86d5a0e83570af7a36cdcf946	41c5e48c0d6d1081bf9f4887f6d47606	ec46d2554ec6745bd25c89eacbf2838f	0	2026-11-26 01:32:10.438
4d626770fddb4f5c759f270430fe1db4	41c5e48c0d6d1081bf9f4887f6d47606	e3c7a43c3bf49f56d6ab700e270e1114	0	2026-11-26 01:32:10.438
f209672a3e014941a8ff550dfdf277a9	0d290dddef2c688b263d34f1dbf3c801	fd6753b0084a2074f64f6c3bab3ff032	0	2026-11-26 01:32:10.438
090b152383f983de02e868571ea8e49c	0d290dddef2c688b263d34f1dbf3c801	7d1f963d67dfe200572b8a84f6f1afa7	0	2026-11-26 01:32:10.438
f2321d313db4f0e6121f8ba63ae32051	0d290dddef2c688b263d34f1dbf3c801	fad47f8b8a28490abed1f058bf24c164	0	2026-11-26 01:32:10.438
\.


--
-- Data for Name: sys_user_tenant; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_user_tenant (id, user_id, tenant_id, status, create_time) FROM stdin;
\.


--
-- Data for Name: sys_user_watermark; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_user_watermark (user_id, enabled, enforced, content, density, updated_by, updated_at) FROM stdin;
\.


--
-- Data for Name: sys_watermark_setting; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_watermark_setting (tenant_id, enabled, mode, content, density, opacity, rotate, font_size, updated_by, updated_at) FROM stdin;
\.


--
-- Data for Name: sys_webhook; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_webhook (id, tenant_id, app_id, event, url, secret, status, del_flag, create_time, update_time) FROM stdin;
\.


--
-- Data for Name: sys_webhook_delivery; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_webhook_delivery (id, webhook_id, event, status, attempts, response_code, error, payload, create_time) FROM stdin;
\.


--
-- Data for Name: task; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.task (id, tenant_id, title, description, priority, status, assignee_id, due_date, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: tool_storage; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tool_storage (id, name, file_name, ext_name, path, type, size, user_id, tenant_id, created_at, updated_at) FROM stdin;
\.


--
-- Name: base_calendar_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.base_calendar_id_seq', 1, false);


--
-- Name: base_schedule_event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.base_schedule_event_id_seq', 1, false);


--
-- Name: base_schedule_reminder_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.base_schedule_reminder_log_id_seq', 1, false);


--
-- Name: biz_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.biz_order_id_seq', 1, false);


--
-- Name: customer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.customer_id_seq', 5, true);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.migrations_id_seq', 6, true);


--
-- Name: supplier_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.supplier_id_seq', 1, false);


--
-- Name: sys_config_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sys_config_id_seq', 34, true);


--
-- Name: sys_file_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sys_file_id_seq', 1, false);


--
-- Name: sys_region_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sys_region_id_seq', 1, false);


--
-- Name: sys_tenant_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sys_tenant_id_seq', 1, false);


--
-- Name: sys_tenant_usage_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sys_tenant_usage_id_seq', 1, false);


--
-- Name: sys_user_tenant_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sys_user_tenant_id_seq', 3, true);


--
-- Name: task_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.task_id_seq', 1, false);


--
-- Name: tool_storage_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tool_storage_id_seq', 1, false);


--
-- Name: sys_permission PK_007ea20aaa05db860bcba9cd624; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_permission
    ADD CONSTRAINT "PK_007ea20aaa05db860bcba9cd624" PRIMARY KEY (id);


--
-- Name: sys_depart PK_03baf13755e46965070bce2cfa4; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_depart
    ADD CONSTRAINT "PK_03baf13755e46965070bce2cfa4" PRIMARY KEY (id);


--
-- Name: base_schedule_reminder_log PK_062385ebcf7f0b738ce9c3bc72b; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_schedule_reminder_log
    ADD CONSTRAINT "PK_062385ebcf7f0b738ce9c3bc72b" PRIMARY KEY (id);


--
-- Name: sys_message_user PK_0ae527f115231f1f3b82ed367d6; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_message_user
    ADD CONSTRAINT "PK_0ae527f115231f1f3b82ed367d6" PRIMARY KEY (id);


--
-- Name: sys_role PK_12875ba0686cf845f353704dc7b; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_role
    ADD CONSTRAINT "PK_12875ba0686cf845f353704dc7b" PRIMARY KEY (id);


--
-- Name: sys_user_watermark PK_18f819fbb0b34760f21206e97ab; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_user_watermark
    ADD CONSTRAINT "PK_18f819fbb0b34760f21206e97ab" PRIMARY KEY (user_id);


--
-- Name: sys_user_tenant PK_264e0cf5fde6e21b35c35dfe463; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_user_tenant
    ADD CONSTRAINT "PK_264e0cf5fde6e21b35c35dfe463" PRIMARY KEY (id);


--
-- Name: sys_message PK_28eed926c94382ecef278928108; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_message
    ADD CONSTRAINT "PK_28eed926c94382ecef278928108" PRIMARY KEY (id);


--
-- Name: supplier PK_2bc0d2cab6276144d2ff98a2828; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier
    ADD CONSTRAINT "PK_2bc0d2cab6276144d2ff98a2828" PRIMARY KEY (id);


--
-- Name: sys_user_role PK_2e8de9f75bef43b05dc1eb09ed5; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_user_role
    ADD CONSTRAINT "PK_2e8de9f75bef43b05dc1eb09ed5" PRIMARY KEY (user_id, role_id);


--
-- Name: sys_user_post PK_301c0cf062718f1e65debb28a2b; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_user_post
    ADD CONSTRAINT "PK_301c0cf062718f1e65debb28a2b" PRIMARY KEY (user_id, post_id);


--
-- Name: tool_storage PK_359622b58f376fc270d8d379ba9; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tool_storage
    ADD CONSTRAINT "PK_359622b58f376fc270d8d379ba9" PRIMARY KEY (id);


--
-- Name: sys_tenant PK_367c0ed135176f2c852b5c4ea8e; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_tenant
    ADD CONSTRAINT "PK_367c0ed135176f2c852b5c4ea8e" PRIMARY KEY (id);


--
-- Name: sys_user_depart PK_396244d586f3f3afaab168746fa; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_user_depart
    ADD CONSTRAINT "PK_396244d586f3f3afaab168746fa" PRIMARY KEY (user_id, dep_id);


--
-- Name: sys_tenant_menu PK_427e6220ae85ab39455170c483d; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_tenant_menu
    ADD CONSTRAINT "PK_427e6220ae85ab39455170c483d" PRIMARY KEY (id);


--
-- Name: sys_announcement PK_499e23c803a5b41f7a0d3eeb3f3; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_announcement
    ADD CONSTRAINT "PK_499e23c803a5b41f7a0d3eeb3f3" PRIMARY KEY (id);


--
-- Name: sys_app PK_596c093d140483f0f4a9f5abef1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_app
    ADD CONSTRAINT "PK_596c093d140483f0f4a9f5abef1" PRIMARY KEY (id);


--
-- Name: sys_watermark_setting PK_5e4a29c4379ab01484b95ef94f8; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_watermark_setting
    ADD CONSTRAINT "PK_5e4a29c4379ab01484b95ef94f8" PRIMARY KEY (tenant_id);


--
-- Name: sys_user_setting PK_61686928524de9ac86814c44b5d; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_user_setting
    ADD CONSTRAINT "PK_61686928524de9ac86814c44b5d" PRIMARY KEY (user_id);


--
-- Name: sys_position PK_64eaf925b09119c29cd39b6723e; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_position
    ADD CONSTRAINT "PK_64eaf925b09119c29cd39b6723e" PRIMARY KEY (id);


--
-- Name: sys_webhook_delivery PK_6d64983806fd00fb0b0d2241fc9; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_webhook_delivery
    ADD CONSTRAINT "PK_6d64983806fd00fb0b0d2241fc9" PRIMARY KEY (id);


--
-- Name: sys_region PK_764cd7fddd7c7828ae0cf536f5e; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_region
    ADD CONSTRAINT "PK_764cd7fddd7c7828ae0cf536f5e" PRIMARY KEY (id);


--
-- Name: sys_user_backup_code PK_7f2bf37a789c79daf4f83195218; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_user_backup_code
    ADD CONSTRAINT "PK_7f2bf37a789c79daf4f83195218" PRIMARY KEY (id);


--
-- Name: sys_config PK_8791cee36df4c4d04a9acffed27; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_config
    ADD CONSTRAINT "PK_8791cee36df4c4d04a9acffed27" PRIMARY KEY (id);


--
-- Name: biz_order PK_884e2b9043759b647945fdb2c39; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.biz_order
    ADD CONSTRAINT "PK_884e2b9043759b647945fdb2c39" PRIMARY KEY (id);


--
-- Name: sys_dict_item PK_88f1e2a3113ea467e938dfb8af3; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_dict_item
    ADD CONSTRAINT "PK_88f1e2a3113ea467e938dfb8af3" PRIMARY KEY (id);


--
-- Name: sys_log_change PK_8c12430eddad32bf0f5b82b526f; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_log_change
    ADD CONSTRAINT "PK_8c12430eddad32bf0f5b82b526f" PRIMARY KEY (id);


--
-- Name: migrations PK_8c82d7f526340ab734260ea46be; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT "PK_8c82d7f526340ab734260ea46be" PRIMARY KEY (id);


--
-- Name: sys_webhook PK_945f41220da8298eab2bd5e533b; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_webhook
    ADD CONSTRAINT "PK_945f41220da8298eab2bd5e533b" PRIMARY KEY (id);


--
-- Name: sys_role_permission PK_980f2d8e546d791d992408b2c40; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_role_permission
    ADD CONSTRAINT "PK_980f2d8e546d791d992408b2c40" PRIMARY KEY (role_id, permission_id);


--
-- Name: base_schedule_event PK_a704b63469f8c3f98f943c5ff03; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_schedule_event
    ADD CONSTRAINT "PK_a704b63469f8c3f98f943c5ff03" PRIMARY KEY (id);


--
-- Name: customer PK_a7a13f4cacb744524e44dfdad32; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT "PK_a7a13f4cacb744524e44dfdad32" PRIMARY KEY (id);


--
-- Name: sys_log PK_a820dafdcd358af9d85bff206eb; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_log
    ADD CONSTRAINT "PK_a820dafdcd358af9d85bff206eb" PRIMARY KEY (id);


--
-- Name: sys_user_supervise_dept PK_aa243becd4dc7f3394d8b64a8be; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_user_supervise_dept
    ADD CONSTRAINT "PK_aa243becd4dc7f3394d8b64a8be" PRIMARY KEY (id);


--
-- Name: sys_user PK_b286272b5d723fa76dca97a159e; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_user
    ADD CONSTRAINT "PK_b286272b5d723fa76dca97a159e" PRIMARY KEY (id);


--
-- Name: sys_app_secret PK_b702fdb7db37bc0d52afc494244; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_app_secret
    ADD CONSTRAINT "PK_b702fdb7db37bc0d52afc494244" PRIMARY KEY (id);


--
-- Name: sys_level PK_b9956871f98f63095825bd930a1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_level
    ADD CONSTRAINT "PK_b9956871f98f63095825bd930a1" PRIMARY KEY (id);


--
-- Name: sys_dict PK_c99797ac6e991ce88c288e0f235; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_dict
    ADD CONSTRAINT "PK_c99797ac6e991ce88c288e0f235" PRIMARY KEY (id);


--
-- Name: sys_quartz_job PK_d521bf70e987519dfc0130f6036; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_quartz_job
    ADD CONSTRAINT "PK_d521bf70e987519dfc0130f6036" PRIMARY KEY (id);


--
-- Name: sys_tenant_usage PK_d813dbfd81312d77b78c6b184e2; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_tenant_usage
    ADD CONSTRAINT "PK_d813dbfd81312d77b78c6b184e2" PRIMARY KEY (id);


--
-- Name: base_calendar PK_e2a12b34e2e1d52cac4f5d0b66c; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_calendar
    ADD CONSTRAINT "PK_e2a12b34e2e1d52cac4f5d0b66c" PRIMARY KEY (id);


--
-- Name: sys_file PK_e8e4a557508fee12fe94af11149; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_file
    ADD CONSTRAINT "PK_e8e4a557508fee12fe94af11149" PRIMARY KEY (id);


--
-- Name: task PK_fb213f79ee45060ba925ecd576e; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT "PK_fb213f79ee45060ba925ecd576e" PRIMARY KEY (id);


--
-- Name: sys_region UQ_413d9027d60aab767e88b6aa6ac; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_region
    ADD CONSTRAINT "UQ_413d9027d60aab767e88b6aa6ac" UNIQUE (area_code);


--
-- Name: sys_user UQ_9e7164b2f1ea1348bc0eb0a7da4; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_user
    ADD CONSTRAINT "UQ_9e7164b2f1ea1348bc0eb0a7da4" UNIQUE (username);


--
-- Name: sys_user UQ_d6651dc2f7e4cda2f6cd6eb3c42; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_user
    ADD CONSTRAINT "UQ_d6651dc2f7e4cda2f6cd6eb3c42" UNIQUE (work_no);


--
-- Name: sys_tenant UQ_d85db5d488020bb73d97f8d86d2; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_tenant
    ADD CONSTRAINT "UQ_d85db5d488020bb73d97f8d86d2" UNIQUE (code);


--
-- Name: sys_position_role pk_position_role; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_position_role
    ADD CONSTRAINT pk_position_role PRIMARY KEY (id);


--
-- Name: IDX_0618ed8afbd700f37a9b017cb3; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_0618ed8afbd700f37a9b017cb3" ON public.sys_user_post USING btree (post_id);


--
-- Name: IDX_095d025f515f2935d3a900cc9e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_095d025f515f2935d3a900cc9e" ON public.sys_user_depart USING btree (dep_id);


--
-- Name: IDX_212c96df7321e7be66634bb554; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_212c96df7321e7be66634bb554" ON public.sys_role_permission USING btree (permission_id);


--
-- Name: IDX_71b4edf9aedbd3e5707156e80a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_71b4edf9aedbd3e5707156e80a" ON public.sys_user_role USING btree (user_id);


--
-- Name: IDX_ca1ecee13191b16796f3744e43; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_ca1ecee13191b16796f3744e43" ON public.sys_user_depart USING btree (user_id);


--
-- Name: IDX_cafe50ffac8beaf0e03bc9a474; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cafe50ffac8beaf0e03bc9a474" ON public.sys_role_permission USING btree (role_id);


--
-- Name: IDX_e380ce9b20b04a1b3315083382; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_e380ce9b20b04a1b3315083382" ON public.sys_user_post USING btree (user_id);


--
-- Name: IDX_e8300bfcf561ed417f5f02c677; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_e8300bfcf561ed417f5f02c677" ON public.sys_user_role USING btree (role_id);


--
-- Name: idx_announce_tenant_del_send; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_announce_tenant_del_send ON public.sys_announcement USING btree (tenant_id, del_flag, send_status);


--
-- Name: idx_app_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_app_tenant ON public.sys_app USING btree (tenant_id);


--
-- Name: idx_appsecret_app; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_appsecret_app ON public.sys_app_secret USING btree (app_id, status);


--
-- Name: idx_backup_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_backup_user ON public.sys_user_backup_code USING btree (user_id, used_at);


--
-- Name: idx_biz_order_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_biz_order_tenant ON public.biz_order USING btree (tenant_id);


--
-- Name: idx_calendar_owner; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_calendar_owner ON public.base_calendar USING btree (owner_id);


--
-- Name: idx_change_record; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_change_record ON public.sys_log_change USING btree (table_name, record_id, create_time);


--
-- Name: idx_change_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_change_time ON public.sys_log_change USING btree (create_time);


--
-- Name: idx_config_group; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_config_group ON public.sys_config USING btree (config_group);


--
-- Name: idx_customer_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_customer_tenant ON public.customer USING btree (tenant_id);


--
-- Name: idx_delivery_hook; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_delivery_hook ON public.sys_webhook_delivery USING btree (webhook_id, create_time);


--
-- Name: idx_delivery_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_delivery_time ON public.sys_webhook_delivery USING btree (create_time);


--
-- Name: idx_event_calendar; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_event_calendar ON public.base_schedule_event USING btree (calendar_id);


--
-- Name: idx_event_remind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_event_remind ON public.base_schedule_event USING btree (remind_at, is_reminded);


--
-- Name: idx_event_user_start; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_event_user_start ON public.base_schedule_event USING btree (user_id, start_time);


--
-- Name: idx_log_tenant_seq; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_log_tenant_seq ON public.sys_log USING btree (tenant_id, seq);


--
-- Name: idx_log_user_read; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_log_user_read ON public.base_schedule_reminder_log USING btree (user_id, is_read);


--
-- Name: idx_message_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_message_tenant ON public.sys_message USING btree (tenant_id, created_at);


--
-- Name: idx_message_user_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_message_user_user ON public.sys_message_user USING btree (user_id, is_read);


--
-- Name: idx_position_role_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_position_role_role ON public.sys_position_role USING btree (role_id);


--
-- Name: idx_quartz_job_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_quartz_job_status ON public.sys_quartz_job USING btree (status);


--
-- Name: idx_quartz_job_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_quartz_job_tenant ON public.sys_quartz_job USING btree (tenant_id);


--
-- Name: idx_sd_depart_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sd_depart_order ON public.sys_depart USING btree (depart_order);


--
-- Name: idx_sd_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sd_parent_id ON public.sys_depart USING btree (parent_id);


--
-- Name: idx_sdi_dict_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sdi_dict_id ON public.sys_dict_item USING btree (dict_id);


--
-- Name: idx_sdi_dict_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sdi_dict_value ON public.sys_dict_item USING btree (dict_id, item_value);


--
-- Name: idx_sdi_sort_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sdi_sort_order ON public.sys_dict_item USING btree (sort_order);


--
-- Name: idx_sdi_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sdi_status ON public.sys_dict_item USING btree (status);


--
-- Name: idx_srp_permission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_srp_permission_id ON public.sys_role_permission USING btree (permission_id);


--
-- Name: idx_srp_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_srp_role_id ON public.sys_role_permission USING btree (role_id);


--
-- Name: idx_su_del_flag; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_su_del_flag ON public.sys_user USING btree (del_flag);


--
-- Name: idx_su_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_su_status ON public.sys_user USING btree (status);


--
-- Name: idx_sud_dep_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sud_dep_id ON public.sys_user_depart USING btree (dep_id);


--
-- Name: idx_sud_dep_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sud_dep_user ON public.sys_user_depart USING btree (dep_id, user_id);


--
-- Name: idx_sud_user_dep_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_sud_user_dep_id ON public.sys_user_depart USING btree (user_id, dep_id);


--
-- Name: idx_sud_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sud_user_id ON public.sys_user_depart USING btree (user_id);


--
-- Name: idx_supervise_dept; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_supervise_dept ON public.sys_user_supervise_dept USING btree (dept_id);


--
-- Name: idx_supervise_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_supervise_user ON public.sys_user_supervise_dept USING btree (user_id);


--
-- Name: idx_supplier_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_supplier_tenant ON public.supplier USING btree (tenant_id);


--
-- Name: idx_sur_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sur_role_id ON public.sys_user_role USING btree (role_id);


--
-- Name: idx_sur_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sur_user_id ON public.sys_user_role USING btree (user_id);


--
-- Name: idx_sys_announcement_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sys_announcement_category ON public.sys_announcement USING btree (msg_category);


--
-- Name: idx_sys_announcement_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sys_announcement_status ON public.sys_announcement USING btree (send_status, send_time);


--
-- Name: idx_sys_announcement_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sys_announcement_tenant ON public.sys_announcement USING btree (tenant_id);


--
-- Name: idx_sys_depart_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sys_depart_tenant ON public.sys_depart USING btree (tenant_id);


--
-- Name: idx_sys_dict_item_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sys_dict_item_tenant ON public.sys_dict_item USING btree (tenant_id);


--
-- Name: idx_sys_dict_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sys_dict_tenant ON public.sys_dict USING btree (tenant_id);


--
-- Name: idx_sys_file_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sys_file_hash ON public.sys_file USING btree (hash);


--
-- Name: idx_sys_file_owner_deleted_update; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sys_file_owner_deleted_update ON public.sys_file USING btree (owner_id, is_deleted, update_time);


--
-- Name: idx_sys_file_owner_parent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sys_file_owner_parent ON public.sys_file USING btree (owner_id, parent_id, is_deleted);


--
-- Name: idx_sys_file_storage_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sys_file_storage_key ON public.sys_file USING btree (storage_key);


--
-- Name: idx_sys_file_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sys_file_tenant ON public.sys_file USING btree (tenant_id);


--
-- Name: idx_sys_file_tenant_owner_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sys_file_tenant_owner_deleted ON public.sys_file USING btree (tenant_id, owner_id, is_deleted, parent_id);


--
-- Name: idx_sys_level_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sys_level_tenant ON public.sys_level USING btree (tenant_id);


--
-- Name: idx_sys_log_tenant_type_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sys_log_tenant_type_time ON public.sys_log USING btree (tenant_id, log_type, create_time);


--
-- Name: idx_sys_log_type_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sys_log_type_time ON public.sys_log USING btree (log_type, create_time);


--
-- Name: idx_sys_log_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sys_log_user ON public.sys_log USING btree (operate_user_name);


--
-- Name: idx_sys_permission_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sys_permission_scope ON public.sys_permission USING btree (scope, del_flag);


--
-- Name: idx_sys_position_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sys_position_tenant ON public.sys_position USING btree (tenant_id);


--
-- Name: idx_sys_region_level; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sys_region_level ON public.sys_region USING btree (level);


--
-- Name: idx_sys_region_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sys_region_name ON public.sys_region USING btree (name);


--
-- Name: idx_sys_region_parent_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sys_region_parent_code ON public.sys_region USING btree (parent_code);


--
-- Name: idx_sys_role_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sys_role_tenant ON public.sys_role USING btree (tenant_id);


--
-- Name: idx_sys_tenant_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sys_tenant_status ON public.sys_tenant USING btree (status, del_flag);


--
-- Name: idx_sys_user_level_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sys_user_level_id ON public.sys_user USING btree (level_id);


--
-- Name: idx_sys_user_tenant_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sys_user_tenant_tenant ON public.sys_user_tenant USING btree (tenant_id);


--
-- Name: idx_task_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_task_tenant ON public.task USING btree (tenant_id);


--
-- Name: idx_tenant_owner; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tenant_owner ON public.sys_tenant USING btree (owner_user_id);


--
-- Name: idx_tenant_usage_period; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tenant_usage_period ON public.sys_tenant_usage USING btree (period);


--
-- Name: idx_tool_storage_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tool_storage_tenant ON public.tool_storage USING btree (tenant_id);


--
-- Name: idx_user_del_create; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_del_create ON public.sys_user USING btree (del_flag, create_time);


--
-- Name: idx_user_del_realname; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_del_realname ON public.sys_user USING btree (del_flag, realname);


--
-- Name: idx_user_post_post; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_post_post ON public.sys_user_post USING btree (post_id);


--
-- Name: idx_webhook_event; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_webhook_event ON public.sys_webhook USING btree (event, status);


--
-- Name: idx_webhook_tenant_del_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_webhook_tenant_del_time ON public.sys_webhook USING btree (tenant_id, del_flag, create_time);


--
-- Name: index_menu_del_flag; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_menu_del_flag ON public.sys_permission USING btree (del_flag);


--
-- Name: index_menu_hidden; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_menu_hidden ON public.sys_permission USING btree (hidden);


--
-- Name: index_menu_sort_no; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_menu_sort_no ON public.sys_permission USING btree (sort_no);


--
-- Name: index_menu_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_menu_status ON public.sys_permission USING btree (status);


--
-- Name: index_menu_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_menu_type ON public.sys_permission USING btree (menu_type);


--
-- Name: index_menu_url; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_menu_url ON public.sys_permission USING btree (url);


--
-- Name: uk_app_client; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uk_app_client ON public.sys_app USING btree (client_id);


--
-- Name: uk_dict_item_value; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uk_dict_item_value ON public.sys_dict_item USING btree (dict_id, item_value);


--
-- Name: uk_log_event_user; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uk_log_event_user ON public.base_schedule_reminder_log USING btree (event_id, user_id);


--
-- Name: uk_log_seq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uk_log_seq ON public.sys_log USING btree (seq);


--
-- Name: uk_message_user; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uk_message_user ON public.sys_message_user USING btree (message_id, user_id);


--
-- Name: uk_position_role; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uk_position_role ON public.sys_position_role USING btree (position_id, role_id);


--
-- Name: uk_supervise_user_dept; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uk_supervise_user_dept ON public.sys_user_supervise_dept USING btree (tenant_id, user_id, dept_id);


--
-- Name: uk_tenant_config_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uk_tenant_config_key ON public.sys_config USING btree (tenant_id, config_key);


--
-- Name: uk_tenant_menu; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uk_tenant_menu ON public.sys_tenant_menu USING btree (tenant_id, permission_id);


--
-- Name: uk_tenant_usage_metric; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uk_tenant_usage_metric ON public.sys_tenant_usage USING btree (tenant_id, metric, period);


--
-- Name: uk_user_role; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uk_user_role ON public.sys_user_role USING btree (user_id, role_id);


--
-- Name: uniq_customer_phone; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_customer_phone ON public.customer USING btree (tenant_id, phone);


--
-- Name: uniq_depart_tenant_org_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_depart_tenant_org_code ON public.sys_depart USING btree (tenant_id, org_code);


--
-- Name: uniq_srp_role_permission; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_srp_role_permission ON public.sys_role_permission USING btree (role_id, permission_id);


--
-- Name: uniq_sur_user_role; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_sur_user_role ON public.sys_user_role USING btree (user_id, role_id);


--
-- Name: uniq_sys_dict_tenant_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_sys_dict_tenant_code ON public.sys_dict USING btree (tenant_id, dict_code);


--
-- Name: uniq_sys_level_tenant_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_sys_level_tenant_name ON public.sys_level USING btree (tenant_id, level_name);


--
-- Name: uniq_sys_position_tenant_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_sys_position_tenant_code ON public.sys_position USING btree (tenant_id, post_code);


--
-- Name: uniq_sys_region_area_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_sys_region_area_code ON public.sys_region USING btree (area_code);


--
-- Name: uniq_sys_role_tenant_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_sys_role_tenant_code ON public.sys_role USING btree (tenant_id, role_code);


--
-- Name: uniq_sys_tenant_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_sys_tenant_code ON public.sys_tenant USING btree (code);


--
-- Name: uniq_sys_user_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_sys_user_email ON public.sys_user USING btree (email);


--
-- Name: uniq_sys_user_phone; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_sys_user_phone ON public.sys_user USING btree (phone);


--
-- Name: uniq_sys_user_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_sys_user_tenant ON public.sys_user_tenant USING btree (user_id, tenant_id);


--
-- Name: uniq_sys_user_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_sys_user_username ON public.sys_user USING btree (username);


--
-- Name: uniq_sys_user_work_no; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_sys_user_work_no ON public.sys_user USING btree (work_no);


--
-- Name: sys_user_post FK_0618ed8afbd700f37a9b017cb3e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_user_post
    ADD CONSTRAINT "FK_0618ed8afbd700f37a9b017cb3e" FOREIGN KEY (post_id) REFERENCES public.sys_position(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_user_depart FK_095d025f515f2935d3a900cc9ea; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_user_depart
    ADD CONSTRAINT "FK_095d025f515f2935d3a900cc9ea" FOREIGN KEY (dep_id) REFERENCES public.sys_depart(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_role_permission FK_212c96df7321e7be66634bb554c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_role_permission
    ADD CONSTRAINT "FK_212c96df7321e7be66634bb554c" FOREIGN KEY (permission_id) REFERENCES public.sys_permission(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_user_role FK_71b4edf9aedbd3e5707156e80a2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_user_role
    ADD CONSTRAINT "FK_71b4edf9aedbd3e5707156e80a2" FOREIGN KEY (user_id) REFERENCES public.sys_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_user_depart FK_ca1ecee13191b16796f3744e432; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_user_depart
    ADD CONSTRAINT "FK_ca1ecee13191b16796f3744e432" FOREIGN KEY (user_id) REFERENCES public.sys_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_role_permission FK_cafe50ffac8beaf0e03bc9a474c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_role_permission
    ADD CONSTRAINT "FK_cafe50ffac8beaf0e03bc9a474c" FOREIGN KEY (role_id) REFERENCES public.sys_role(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_user_post FK_e380ce9b20b04a1b3315083382f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_user_post
    ADD CONSTRAINT "FK_e380ce9b20b04a1b3315083382f" FOREIGN KEY (user_id) REFERENCES public.sys_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_user_role FK_e8300bfcf561ed417f5f02c6776; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_user_role
    ADD CONSTRAINT "FK_e8300bfcf561ed417f5f02c6776" FOREIGN KEY (role_id) REFERENCES public.sys_role(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict CcfwjqNm1IcXT9C6asxqhYaJYKQKk798UPyUjjgYDUfslHoPgR30ls1OA1xGMdc

