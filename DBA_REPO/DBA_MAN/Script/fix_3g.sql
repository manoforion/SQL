 SET NOCOUNT ON;
 /* by friedrich*/


	declare @fvm table 
	(
	listpos int,
	valor_id varchar(100)
	)
	declare @fvm2 table
	(
		cantidad_c int,
		push_hc_tipo varchar(100),
		Push_hc_id_envio int,
		Push_hc_operador int
	)
	--insert into @fvm SELECT *  FROM lista_char('512,513')
	--select * from @fvm
--set fmtonly on; exec [DASHBOARD_SEL_MULTOP] '377', '377'; set fmtonly off

/* by friedrich*/

 
 --SELECT * INTO #t1 FROM lista_char(@suscripciones)
 --insert into @fvm SELECT * FROM lista_char(@suscripciones)
 insert into @fvm values (1,713)
  --sp_help lista_char
  
 insert into @fvm2 SELECT COUNT(*)AS Cantidad_C ,Push_HC_Tipo, Push_HC_id_Envio, Push_HC_Operador  --INTO #t2 
    FROM  Routing1.SmsRouting2_Apps.dbo.Push_HC
    WHERE  Push_HC_Tipo = 'C'
    GROUP BY Push_HC_Tipo , Push_HC_id_Envio, Push_HC_Operador
  
 SELECT  

  ID,
  Nombre,
  Lote,  
  Fecha,
  sum(fvm.Base_inicial) as Base_inicial,
  sum(Base_Efectiva) as Base_Efectiva,
  sum(Cantidad_MTs_Enviados) as Cantidad_MTs_Enviados,
  sum(Enviados) as Enviados,
  sum(Enviados_Error) as Enviados_Error,
  avg(Porc_MTs_Entregado) as Porc_MTs_Entregado,
  sum(Entregados) as Entregados,
  sum(No_entregados) as No_entregados,
  avg(T_envio) as T_envio,
  avg(T_entrega) as T_entrega,
  avg(T_conversion_C) as T_conversion_C,
  avg(T_conversion_E) as T_conversion_E,
  avg(0) as Conversiones,
  estado 
 from   
 (SELECT 
   c.id_operador,	
   L.id_envio as ID,
   e.descripcion as Nombre,
   L.id_envio as Lote,
   e.fecha as Fecha, 
   L.cantidad_detalles as Base_inicial,
   L.cantidad_detalles_exito as Base_Efectiva ,
   L.cantidad_detalles_gateway  as Cantidad_MTs_Enviados, --NO APLICA
   L.cantidad_detalles_gateway_exito as Enviados,
   L.cantidad_detalles_gateway_error as Enviados_Error,
   case L.cantidad_detalles_gateway
   when 0 then 0
   when NULL then 0
   else convert(float,L.cantidad_detalles_gateway_exito)/L.cantidad_detalles_gateway
   end    AS Porc_MTs_Entregado, --NO APLICA
   
   case 
		WHEN c.id_operador = 17 THEN 
			convert(float,L.cantidad_detalles_gateway_exito) 
		   --isnull(L.cantidad_detalles_dlr_ok,0) 
		ELSE 
			convert(float,L.cantidad_detalles_gateway_exito) - isnull(L.cantidad_detalles_dlr_error,0)
		END as Entregados,
	case 
		WHEN c.id_operador = 17 THEN 	
			0 
		ELSE 
			isnull(L.cantidad_detalles_dlr_error,0) 
		END as No_entregados,
   case L.cantidad_detalles_exito
   when 0 then 0
   when NULL then 0
   else convert(float,L.cantidad_detalles_gateway_exito)/L.cantidad_detalles_exito
   end    AS T_envio,
   
   case L.cantidad_detalles_gateway_exito
   when 0 then 0
   when NULL then 0
   
   else 
		case 
		When c.id_operador = 17 then L.cantidad_detalles_exito
		else 
			convert(float,isnull(L.cantidad_detalles_dlr_ok,0))/L.cantidad_detalles_gateway_exito
		end 
   end    AS T_entrega,
   
   case L.cantidad_detalles_exito
   when 0 then 0
   when NULL then 0
   else convert(float,10)/L.cantidad_detalles_exito
   end    AS T_conversion_C,
   case L.cantidad_detalles_gateway_exito
   when 0 then 0
   when NULL then 0
   else convert(float,10)/L.cantidad_detalles_gateway_exito
   end    AS T_conversion_E,
   --0 as Conversiones 
   HC.Cantidad_C as Conversiones,
   L.estado
   
 FROM       lote L
               INNER JOIN (SELECT * FROM Clientes.dbo.Campaña  WHERE      (id_campaña IN
               (SELECT     id_campaña
                FROM          Clientes.dbo.campaña_lista
                WHERE      id_lista IN
                (SELECT     id_lista
                FROM          Clientes.dbo.lista
                WHERE      id_suscripcion IN (
       (select  valor_id from @fvm)
       ))))) C ON L.id_campaña = C.id_campaña
                         INNER JOIN clientes.dbo.envio e ON L.id_envio = e.id_envio
                         LEFT JOIN  @fvm2 HC on HC.Push_HC_Id_Envio =  l.id_envio and HC.Push_HC_Operador = C.id_operador
                       
               where L.tarea <> 'InscripcionEntel'  and 
			   
			   L.id_envio in (54625)) fvm --and  L.cantidad_detalles_exito >5

      group by ID,Lote,estado, Nombre,Fecha
      
    