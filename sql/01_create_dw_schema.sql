-- DDL para Data Warehouse: esquema dw_analytics

CREATE SCHEMA IF NOT EXISTS dw_analytics;

-- Dimensión clientes
CREATE TABLE IF NOT EXISTS dw_analytics.dim_clientes (
  cliente_sk SERIAL PRIMARY KEY,
  customer_id INTEGER,
  country TEXT,
  nombre TEXT,
  etiqueta TEXT,
  created_at TIMESTAMP DEFAULT now()
);

-- Dimensión productos
CREATE TABLE IF NOT EXISTS dw_analytics.dim_productos (
  producto_sk SERIAL PRIMARY KEY,
  stock_code TEXT,
  description TEXT,
  categoria TEXT,
  created_at TIMESTAMP DEFAULT now()
);

-- Dimensión fecha (día)
CREATE TABLE IF NOT EXISTS dw_analytics.dim_fecha (
  fecha_sk SERIAL PRIMARY KEY,
  fecha DATE NOT NULL,
  anio INTEGER,
  mes INTEGER,
  dia INTEGER,
  trimestre INTEGER,
  dia_semana INTEGER
);

-- Tabla de hechos: fact_ventas (una fila = un producto en una factura)
CREATE TABLE IF NOT EXISTS dw_analytics.fact_ventas (
  fact_id BIGSERIAL PRIMARY KEY,
  invoice_no TEXT,
  cliente_sk INTEGER NOT NULL,
  producto_sk INTEGER NOT NULL,
  fecha_sk INTEGER NOT NULL,
  cantidad INTEGER NOT NULL,
  precio_unitario NUMERIC(12,4) NOT NULL,
  monto_total_calculado NUMERIC(18,4) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,
  line_comment TEXT,
  created_at TIMESTAMP DEFAULT now(),
  CONSTRAINT fk_cliente FOREIGN KEY (cliente_sk) REFERENCES dw_analytics.dim_clientes(cliente_sk),
  CONSTRAINT fk_producto FOREIGN KEY (producto_sk) REFERENCES dw_analytics.dim_productos(producto_sk),
  CONSTRAINT fk_fecha FOREIGN KEY (fecha_sk) REFERENCES dw_analytics.dim_fecha(fecha_sk)
);

-- Índices básicos
CREATE INDEX IF NOT EXISTS idx_factventas_invoice_no ON dw_analytics.fact_ventas(invoice_no);
CREATE INDEX IF NOT EXISTS idx_factventas_cliente_sk ON dw_analytics.fact_ventas(cliente_sk);
CREATE INDEX IF NOT EXISTS idx_factventas_fecha_sk ON dw_analytics.fact_ventas(fecha_sk);

-- Comentarios breves
COMMENT ON TABLE dw_analytics.dim_clientes IS 'Clientes con clave subrogada (cliente_sk).';
COMMENT ON TABLE dw_analytics.dim_productos IS 'Productos con clave subrogada (producto_sk).';
COMMENT ON TABLE dw_analytics.dim_fecha IS 'Dimensión de fechas (día).';
COMMENT ON TABLE dw_analytics.fact_ventas IS 'Hechos de ventas a nivel línea.';
