SELECT claim.claimnumber                                                                                                                                                                                                  AS claimnumber,
    DECODE (claim.mx_iscondition,1,'SI','NO')                                                                                                                                                                               AS estaCondicionado ,
    MXS00100727A.sp_getindicadorriesgo(claim.id)                                                                                                                                                                                         AS indicador_riesgo,
    MXS00100727A.sp_getreaseguro(claim.MX_REINSURANCEREASONS)                                                                                                                                                                            AS reaseguro,
    MXS00100727A.sp_getestatussiniestro(claim.state)                                                                                                                                                                                     AS statusSiniestro,
    MXS00100727A.sp_getlosscause(claim.losscause)                                                                                                                                                                                        AS causa_siniestro,
    MXS00100727A.sp_getcategoriasiniestro(claim.mx_category)                                                                                                                                                                             AS categoria_sini,
    DECODE(claim.mx_equaladjusterlocation,1, 
           NVL(MXS00100727A.sp_getestadosiniestro(
                                     (SELECT addressLoss.state FROM MXS00100727A.cc_address addressLoss WHERE addressLoss.id = claim.losslocationid)
                                    ), 
               MXS00100727A.sp_getestadosiniestro(
                                     (SELECT addresAtn.state FROM MXS00100727A.cc_address addresAtn WHERE addresatn.id = claim.mx_adjusterlocationid)
                                    )
              ), 
           MXS00100727A.sp_getestadosiniestro(
                                 (SELECT addressLoss.state FROM MXS00100727A.cc_address addressLoss WHERE addressLoss.id = claim.losslocationid)
                                )
          )                                                                                                                                                                                                                 AS Estado_sini,
    DECODE(claim.mx_equaladjusterlocation,1,
           NVL(
               (SELECT addressLoss.city FROM MXS00100727A.cc_address addressLoss WHERE addressLoss.id = claim.losslocationid),
               (SELECT addresAtn.city FROM MXS00100727A.cc_address addresAtn WHERE addresatn.id = claim.mx_adjusterlocationid) 
              ),
           (SELECT addressLoss.city FROM MXS00100727A.cc_address addressLoss WHERE addressLoss.id = claim.losslocationid)
          )                                                                                                                                                                                                                 AS Ciudad_sini,
    MXS00100727A.sp_get_attnzone_division(NVL(
                                 (SELECT addresAtn.Mx_AttentionZone FROM MXS00100727A.cc_address addresAtn WHERE addresatn.id = claim.mx_adjusterlocationid), 
                                 (SELECT addressLoss.Mx_AttentionZone FROM MXS00100727A.cc_address addressLoss WHERE addressLoss.id = claim.losslocationid)
                                )
                            )                                                                                                                                                                                               AS Division,
    MXS00100727A.sp_get_attnzone_zone(NVL(
                             (SELECT addresAtn.Mx_AttentionZone FROM MXS00100727A.cc_address addresAtn WHERE addresatn.id = claim.mx_adjusterlocationid), 
                             (SELECT addressLoss.Mx_AttentionZone FROM MXS00100727A.cc_address addressLoss WHERE addressLoss.id = claim.losslocationid)
                            )
                        )                                                                                                                                                                                                   AS Zona,
    NVL(
        (SELECT addresAtn.Mx_AttentionZone FROM MXS00100727A.cc_address addresAtn WHERE addresatn.id = claim.mx_adjusterlocationid),
        (SELECT addressLoss.Mx_AttentionZone FROM MXS00100727A.cc_address addressLoss WHERE addressLoss.id = claim.losslocationid)
       )                                                                                                                                                                                                                    AS LossLocAttZone,
    NVL((SELECT addresAtn.Mx_AttentionZone FROM MXS00100727A.cc_address addresAtn WHERE addresatn.id = claim.mx_adjusterlocationid),'')                                                                                                          AS AdjLocAttZone,
    DECODE(accountPolicy.acctpolicynumber, NULL,NULL, TRUNC( accountPolicy.EndDate))                                                                                                                                        AS fecha_contable,
    TRUNC(claim.lossdate)                                                                                                                                                                                                   AS lossdate,
    TRUNC(claim.reporteddate)                                                                                                                                                                                               AS reportedDate,
    TRUNC(claim.closedate)                                                                                                                                                                                                  AS closedate,
    NVL((SELECT pol.policynumber FROM MXS00100727A.cc_policy pol WHERE pol.id = claim.policyid),'')                                                                                                                                              AS poliza,
    NVL((SELECT pol.mx_clausenumber FROM MXS00100727A.cc_policy pol WHERE pol.id = claim.policyid),'')                                                                                                                                           AS inciso,
    MXS00100727A.sp_getpolicytype((SELECT pol.policytype FROM MXS00100727A.cc_policy pol WHERE pol.id = claim.policyid))                                                                                                                              AS policy_type,
    MXS00100727A.sp_getsubramo(to_number((SELECT pol.mx_subramo FROM MXS00100727A.cc_policy pol WHERE pol.id = claim.policyid)))                                                                                                                      AS subramo,
    TRUNC((SELECT pol.EffectiveDate FROM MXS00100727A.cc_policy pol WHERE pol.id = claim.policyid))                                                                                                                                      AS pol_inicio_vigencia,
    TRUNC( (SELECT pol.ExpirationDate FROM MXS00100727A.cc_policy pol WHERE pol.id = claim.policyid))                                                                                                                                    AS pol_fecha_expira,
    MXS00100727A.sp_nombrepersona(claim.id,1)                                                                                                                                                                                            AS nombre_asegurado,
    MXS00100727A.sp_getpolicystatus((SELECT pol.status FROM MXS00100727A.cc_policy pol WHERE pol.id = claim.policyid))                                                                                                                                AS policy_status,
    NVL((SELECT pol.Mx_Collectionstatus FROM MXS00100727A.cc_policy pol WHERE pol.id = claim.policyid),'')                                                                                                                                       AS status_cobranza,
    'NA'                                                                                                                                                                                                                    AS oficina_pago,
    NVL((SELECT pol.Mx_rate FROM MXS00100727A.cc_policy pol WHERE pol.id = claim.policyid),'')                                                                                                                                                   AS indice_tarifa,
    MXS00100727A.sp_gettipotransaccion(tr.subtype)                                                                                                                                                                                       AS tipotransaccion,
    ABS(MXS00100727A.sp_getMontoTransCoins(tr.id,tr.subtype,mxtr.id,claim.policyid,claim.lossdate, NVL(mxtr.iscoinsurance,0)))*DECODE(mxtr.importtype,'02',-1,1)                                                                         AS montotransaccion,
    TRUNC(tr.createtime)                                                                                                                                                                                                    AS FhTransaccion,
    MXS00100727A.sp_getusuariotransaccion(tr.createuserid)                                                                                                                                                                               AS usuario,
    tr.publicid                                                                                                                                                                                                             AS publicid,
    MXS00100727A.sp_gettipoincidente(incident.subtype)                                                                                                                                                                                   AS tipoIncidente,
    vh.Mx_description                                                                                                                                                                                                       AS descripcio_vh,
    vh.Make                                                                                                                                                                                                                 AS Marca,
    vh.model                                                                                                                                                                                                                AS Modelo,
    vh.Vin                                                                                                                                                                                                                  AS Serie,
    vh.mx_enginenumber                                                                                                                                                                                                      AS num_motor,
    vh.licensePlate                                                                                                                                                                                                         AS placas,
    MXS00100727A.sp_nombrepersona(claim.id,10003,incident.id)                                                                                                                                                                            AS conductor,
    MXS00100727A.sp_getEdadPersona(claim.id,10003,incident.id)                                                                                                                                                                           AS edad_conductor,
    MXS00100727A.sp_getSexoPersona(claim.id,10003,incident.id)                                                                                                                                                                           AS sexo_conductor,
    MXS00100727A.sp_NombrePersona(claim.id,10011,incident.id)                                                                                                                                                                            AS nombre_lesionado,
    MXS00100727A.sp_getRolLesionado(claim.id,10011,incident.id)                                                                                                                                                                          AS rol_lesionado,
    MXS00100727A.sp_getdescripciontna(incident.MX_THIRDNOAUTODESC)                                                                                                                                                                       AS descripcion_tna,
    MXS00100727A.sp_NombrePersona(claim.id,10058,incident.id)                                                                                                                                                                            AS contacto_tna,
    incident.description                                                                                                                                                                                                    AS descripcion_inc,
    DECODE(incident.MX_ISDEAD,1,'SI',0,'NO','N/A')                                                                                                                                                                          AS fallecido_inc,
    DECODE(incident.SUBTYPE, 6,MXS00100727A.sp_gettipodocumentolesionado( incident.MX_INJURYDOCUMENTTYPE), 4,MXS00100727A.sp_gettipodocumentovehiculo( incident.MX_VEHICLEDOCUMENTTYPE), 5,MXS00100727A.sp_gettipodocumentotna( incident.MX_PROPERTYDOCUMENTTYPE)) AS tipo_documento,
    DECODE(incident.SUBTYPE, 6,incident.MX_MEDICALPASSFOLIO, 4, incident.MX_DOCUMENTFOLIO, 5,incident.MX_PROPERTYDOCUMENTFOLIO)                                                                                             AS folio_documento,
    incident.mx_cranefolio                                                                                                                                                                                                  AS folioGrua,
    TRUNC(incident.Mx_DocumentExpDate)                                                                                                                                                                                      AS fecha_expedicion,
    incident.mx_salvageinventory                                                                                                                                                                                            AS numInventario,
    incident.datesalvageassigned                                                                                                                                                                                            AS fhIngresoResguardo,
    DECODE(tr.mx_isinitialreserve,1,'SI','NO')                                                                                                                                                                              AS esReservaInicial,
    MXS00100727A.sp_gettipoexposure(exp.exposuretype)                                                                                                                                                                                    AS exposicion,
    MXS00100727A.sp_getcobertura(exp.primarycoverage)                                                                                                                                                                                    AS cobertura,
    MXS00100727A.sp_gettipocosto(tr.costtype)                                                                                                                                                                                            AS tipoCostoTr,
    MXS00100727A.sp_getcategoriacosto(tr.costcategory)                                                                                                                                                                                   AS categCosto,
    MXS00100727A.sp_gettiporecuperacion(tr.mx_recoverytype)                                                                                                                                                                              AS tipoRecuperacion,
    MXS00100727A.sp_getsubtiporecuperacion(tr.Mx_Subrogsubrecovery2Type)                                                                                                                                                                 AS subsubtipo_recuperacion,
    MXS00100727A.sp_getCategoriaRecuperacion(tr.recoverycategory)                                                                                                                                                                        AS categoria_recup,
    DECODE(
        DECODE(LENGTH(mxtr.ACCOUNT),16,SUBSTR(mxtr.ACCOUNT,9,2),18,SUBSTR(mxtr.ACCOUNT,11,2)),
        '00','MXN','01','UDI','12','USD')  MONEDA,
    MXS00100727A.sp_getstatustransaccion(tr.status)                                                                                                                                                                                      AS statusTr,
    ------------------------------------------------------------------
    mxtr.account                                                                                              AS cuenta_contable,
    mxtr.costcenter                                                                                           AS centrocostoscontable,
    mxtr.movementcode                                                                                         AS codigomovimientocontable,
    DECODE(tr.subtype, 1, NVL(chk.mx_referencenumber,chk.mx_odpreferencenumber) , accountPolicy.acctfilename) AS idArchivoCont, --lo que se genera en CC
    -- para adrc
    accountPolicy.acctpolicynumber AS folio_poliza_contable,--viene solo de
    -- agave
    mxtr.productcode                                                                                                                                                                                                                                       AS codigoproductocontable,
    MXS00100727A.sp_gettipopago(tr.paymenttype)                                                                                                                                                                                                                         AS tipoPago,
    chk.mx_odpreferencenumber                                                                                                                                                                                                                              AS odp,
    MXS00100727A.sp_getstatuspago(chk.status)                                                                                                                                                                                                                           AS StatusPago,
    chk.scheduledsenddate                                                                                                                                                                                                                                  AS fhPagoProg,
    chk.issuedate                                                                                                                                                                                                                                          AS fhpago,
    NVL((SELECT cservice.name FROM MXS00100727A.ccx_com_claimservice cservice WHERE cservice.id     = tr.com_claimserviceid),'')                                                                                                                                                AS tipo_servicio,
    TRUNC((SELECT cservice.createtime FROM MXS00100727A.ccx_com_claimservice cservice WHERE cservice.id     = tr.com_claimserviceid))                                                                                                                                   AS fecha_servicio,
    MXS00100727A.sp_getprestadorservicio((SELECT cservice.providerid FROM MXS00100727A.ccx_com_claimservice cservice WHERE cservice.id     = tr.com_claimserviceid))                                                                                                                 AS proveedor_servicio,
    MXS00100727A.sp_getdocumentoproveedor(chk.Mx_TypeDocument)                                                                                                                                                                                                          AS cuentabancaria,
    mxtr.importtype                                                                                                                                                                                                                                        AS tipo_movimiento,
    chk.checknumber                                                                                                                                                                                                                                        AS no_mov_pago,
    MXS00100727A.sp_getmetodopago(chk.paymentmethod)                                                                                                                                                                                                                    AS metodoPago,
    NVL((SELECT cservice.BPIPreInvoiceId FROM MXS00100727A.ccx_com_claimservice cservice WHERE cservice.id     = tr.com_claimserviceid),'')                                                                                                                                     AS num_pago,
    chk.invoicenumber                                                                                                                                                                                                                                      AS numFactura,
    MXS00100727A.sp_gettotalbruto(chk.id)                                                                                                                                                                                                                               AS monto_bruto,
    MXS00100727A.sp_getmontodescuento(chk.bulkinvoiceiteminfoid)                                                                                                                                                                                                        AS monto_descuento,
    MXS00100727A.sp_getpenalizacion(tr.id,10004)                                                                                                                                                                                                                        AS monto_penalizacion,
    MXS00100727A.sp_getbono(tr.id,10002)                                                                                                                                                                                                                                AS monto_bono,
    MXS00100727A.sp_getbono(tr.id,10001)                                                                                                                                                                                                                                AS monto_award,
    MXS00100727A.sp_getmontoretenciones(tr.id)                                                                                                                                                                                                                          AS monto_retenciones,
    tr.mx_percivareten                                                                                                                                                                                                                                     AS porcierto_retenciones,
    MXS00100727A.sp_getmontoisr(tr.id)                                                                                                                                                                                                                                  AS monto_isr,
    MXS00100727A.sp_getmontoiva(tr.subtype,tr.id,mxtr.AmountId*DECODE(mxtr.importtype,'02',-1,1),tr.mx_percentiva,tr.checkid,mxtr.account)                                                                                                                              AS monto_iva,
    NVL(tr.mx_percentiva,chk.mx_percentageiva)                                                                                                                                                                                                             AS porciento_iva,
    chk.mx_refund                                                                                                                                                                                                                                          AS rembolso,
    MXS00100727A.sp_getprefactura(chk.id)                                                                                                                                                                                                                               AS prefact_pago_masivo,
    chk.payto                                                                                                                                                                                                                                              AS pagado_a,
    DECODE(tr.subtype,1,MXS00100727A.sp_gettotalpagado(chk.id),0) AS total_pagado,
    MXS00100727A.sp_getrfcpagadoa(chk.id)                                                                                                                                                                                                                               AS rfc,
    vh.Mx_InsuredAmountPerc                                                                                                                                                                                                                                AS per_suma_aseg,
    vh.Mx_InsuredAmount                                                                                                                                                                                                                                    AS valor_vehiculo,
    vh.Mx_VehicleValueDescription                                                                                                                                                                                                                          AS tipo_valor,
    vh.id,
    DECODE(tr.subtype, 1,
           --nvl(mxtr.PaymentConcept,
           MXS00100727A.sp_getpaymentconcept(tr.id, mxtr.AmountId)
           , null)                                                                                                                                               AS concepto_pago,
    MXS00100727A.sp_get_attnzone_office(NVL(
                               (SELECT addresAtn.Mx_AttentionZone FROM MXS00100727A.cc_address addresAtn WHERE addresatn.id = claim.mx_adjusterlocationid), 
                               (SELECT addressLoss.Mx_AttentionZone FROM MXS00100727A.cc_address addressLoss WHERE addressLoss.id = claim.losslocationid)
                              )
                          )                                                                                                                                       AS Oficina,
    NVL(MXS00100727A.sp_get_numsolicitud_prefac(chk.id),MXS00100727A.sp_get_numsolicitud_chk(chk.id))                                                                                       AS Numero_Solicitud,
    NVL(MXS00100727A.sp_get_numagrup_prefac(chk.id),MXS00100727A.sp_get_numagrup_chk(chk.id))                                                                                               AS Numero_Agrupacion,
    MXS00100727A.sp_get_exposure_claimorder(tr.id)                                                                                                                             AS Numero_Exposicion,
    DECODE(claim.mx_mode,10001,'COLISION', 10002,'ROBO',10003,'CRISTALES', 'OTRO')                                                                                AS Tipo_Siniestro,
    MXS00100727A.sp_GetCoInsuranceGroup(claim.policyid,claim.lossdate)                                                                                                         AS Coaseguro,
	--litigios
	MT.MX_OBLIGATIONDATE AS FECHA_INICIO_OBLIGACION,
 MT.MX_OPENDATE AS FECHA_APERTURA,
 MTC.MX_FOLIODATE AS FECHA_ORDENADA,
 MTC.MX_FOLIO AS FOLIO_ORDENADA,
MTT.L_ES_MX AS TIPO_LITIGIO,
 MT.NAME AS FOLIO_LITIGIO,
 MTS.L_ES_MX AS ESTADO_PROCEDIMIENTO,
 LSTL.COMPLETIONDATE AS FECHA_ULTIMO_ESTADO_PROCESAL,
 MT.TRIALDATE AS FECHA_INICIO,
 DECODE (MT.CLOSEDATE, NULL, 'ABIERTO', 'CERRADO') AS ESTATUS_LITIGIO,
 MT.CLOSEDATE AS CLOSEDATEL,
 NVL((SELECT
 CONT.FIRSTNAME || ' ' || CONT.LASTNAME || ' ' || CONT.MX_LASTNAME2 FROM MXS00100727A.cc_CONTACT CONT WHERE CONT.ID=MTPT.CONTACTID),'') AS CONTACTO,
 --COT.L_ES_MX AS EXPOSICIONL
MXS00100727A.sp_getcobertura(exp.primarycoverage) AS EXPOSICIONL
 --fin litigios
  FROM MXS00100727A.cc_TRANSACTION tr
  inner JOIN MXS00100727A.ccx_mx_transaction mxtr
  ON ( mxtr.transaction  =tr.id
  AND NVL(mxtr.retired,0)=0 ) AND tr.retired     = 0  and mxtr.account like '2121%'
  AND tr.costcategory not in (10299,10298,10297,10296,10295,10294,10293,10292,10291,10290,10289,10288,10287,10286,10285,10284,10283,10282,10281,10280,10279,10278,10277,10276,10275,10268,10267,10266,10265,10264,10263,10260,10259,10176,10175,10146,10118,10065,10059,10019)
  INNER JOIN MXS00100727A.cc_claim claim
  ON tr.claimid = claim.id AND claim.LOSSTYPE = 10001 and claim.state <> 1 and claim.MX_SINERGYCLAIM_PR != 1
  LEFT OUTER JOIN MXS00100727A.cc_exposure exp
  ON exp.id = tr.exposureid
  LEFT OUTER JOIN MXS00100727A.cc_incident incident
  ON incident.id = exp.incidentid
  inner JOIN MXS00100727A.ccx_mx_accountpolicy accountPolicy
  ON accountPolicy.id = mxtr.mx_AccountPolicy and accountPolicy.acctpolicynumber is not null
  and DECODE(accountPolicy.acctpolicynumber, NULL,NULL, TRUNC( accountPolicy.EndDate))>=(Select to_date(trunc(validsincedate),'dd/mm/yyy') 
/**uncoment to asure accounting month**/
           -- from ccx_mx_accountantmonth where to_char(trunc(validuntildate),'mm/yyyy')=to_char(trunc(sysdate),'mm/yyyy')and retired=0 and statusmonth=10001)
	   from MXS00100727A.ccx_mx_accountantmonth where  retired=0 and statusmonth=10001)
 and DECODE(accountPolicy.acctpolicynumber, NULL,NULL, TRUNC( accountPolicy.EndDate))<=(Select to_date(trunc(validuntildate),'dd/mm/yyy') 
/**uncoment to asure accounting month**/
        --    from ccx_mx_accountantmonth where to_char(trunc(validuntildate),'mm/yyyy')=to_char(trunc(sysdate),'mm/yyyy')and retired=0 and statusmonth=10001)
            from MXS00100727A.ccx_mx_accountantmonth where  retired=0 and statusmonth=10001)
    --LEFT JOIN cc_riskunit ru
    --ON (ru.policyid = pol.id
    --AND ru.retired  =0)
  LEFT OUTER JOIN MXS00100727A.cc_vehicle vh
    --ON (vh.id       = incident.vehicleid
    --AND ru.vehicleid=vh.id)
  ON ( vh.id    = incident.vehicleid
  AND vh.retired=0 )
  LEFT OUTER JOIN MXS00100727A.cc_check chk
  ON chk.id = tr.checkid
  ---litigios
   left JOIN MXS00100727A.ccX_MX_MATTERCALCULATION MTC ON MTC.MX_EXPOSUREID=exp.id  and MTC.RESERVEMATTERTYPE=10002 AND NVL(MTC.retired,0)=0 AND MTC.MX_AMOUNT != 0
   LEFT JOIN MXS00100727A.cc_MATTER MT on MT.id=MTC.MX_MATTERID  
   LEFT JOIN MXS00100727A.ccTL_MATTERTYPE MTT ON MTT.ID=MT.MATTERTYPE
   LEFT JOIN (SELECT CONTACTID, MATTERID, ID FROM
             MXS00100727A.ccX_MX_MATTERPLAINTIFF MTPT WHERE CONTACTID = (SELECT MIN(CONTACTID) 
                        FROM MXS00100727A.ccX_MX_MATTERPLAINTIFF MTPT2 
                        WHERE MTPT2.MATTERID = MTPT.MATTERID )
   ) MTPT ON MTPT.MATTERID=MT.ID
   LEFT JOIN (SELECT LSTL.MATTERID, LSTL.LITIGATIONSTATUS, LSTL.COMPLETIONDATE, LSTL.STARTDATE FROM
             MXS00100727A.cc_LITSTATUSTYPELINE LSTL WHERE ID = (SELECT  MAX(ID)
                         FROM MXS00100727A.cc_LITSTATUSTYPELINE LSTL_MAX 
                         WHERE LSTL_MAX.MATTERID = LSTL.MATTERID
                         AND STARTDATE IS NOT NULL)
             ) LSTL
       ON  LSTL.MATTERID=MT.ID
   LEFT JOIN MXS00100727A.ccTL_MATTERSTATUS MTS ON MTS.ID=LSTL.LITIGATIONSTATUS
  --fin litigios