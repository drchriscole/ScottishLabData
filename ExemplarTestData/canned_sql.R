
##
## Canned SQL statements
##

sql_create_dashv2 = "
    CREATE TABLE DaSH_v2 as
      SELECT *, 
        substring(Reference_Range, 1, case when  CHARINDEX('{', Reference_Range) = 0 then LENGTH(Reference_Range) 
        else CHARINDEX('{', Reference_Range)-1 end) as 'low',
        substring(Reference_Range, case when  CHARINDEX('{', Reference_Range) = 0 then LENGTH(Reference_Range) 
        else CHARINDEX('{', Reference_Range)+1 end, LENGTH(Reference_Range) ) as 'high'
      FROM DaSH
"

sql_create_fhir_dash = "
    CREATE TABLE FHIR_DaSH (
        subject             VARCHAR(50) NOT NULL,
        category            VARCHAR(150) NULL,
        code                VARCHAR(50) NOT NULL,
        effectiveDate       DATE NULL,
        valueQuantity       VARCHAR(50) NULL,
        valueUnit           VARCHAR(50) NULL,
        valueString         VARCHAR(1000) NULL,
        referenceRangeHigh  REAL NULL,
        referenceRangeLow   REAL NULL,
        encounter           VARCHAR(50) NULL,
        specimen            VARCHAR(50) NULL,
        healthBoard         VARCHAR(50) NULL,
        readCodeDescription VARCHAR(250) NULL
    )
"

sql_insert_fhir_dash = "
    INSERT INTO FHIR_DaSH
        (
            subject,
            category,
            code,
            effectiveDate,
            valueQuantity,
            valueUnit,
            valueString,
            referenceRangeHigh,
            referenceRangeLow,
            encounter,
            specimen,
            healthBoard,
            readCodeDescription
        )

    SELECT
        prochi AS subject,
        category AS category,
        read_code AS code,
        CAST(Date_of_Sample AS DATE) AS effectiveDate,
        (case when result/1 != 0 
                 then result 
              when substring(result, 1, 1)='>' or substring(result, 1, 1)='<'
                 then substring(result, 2, LENGTH(result)-1)
              else NULL 
         end
        ) AS valueQuantity,
        test_units AS valueUnit,
        (case when result_extension/1=0 
                 then result_extension 
    		  when result/1=0
                 then result 
    		  else NULL
         end
        ) AS valueString,
        high AS referenceRangeHigh,
        low AS referenceRangeLow,
        NULL AS encounter,
        NULL AS specimen,
        'Grampian' AS healthboard,
        test_description AS readCodeDescription
    FROM DaSH_v2
    WHERE read_code IS NOT NULL
"

sql_create_fhir_hic = "
    CREATE TABLE FHIR_HIC (
        subject             VARCHAR(50) NOT NULL,
        category            VARCHAR(150) NULL,
        code                VARCHAR(50) NOT NULL,
        effectiveDate       DATE NULL,
        valueQuantity       VARCHAR(50) NULL,
        valueUnit           VARCHAR(50) NULL,
        valueString         VARCHAR(1000) NULL,
        referenceRangeHigh  REAL NULL,
        referenceRangeLow   REAL NULL,
        encounter           VARCHAR(50) NULL,
        specimen            VARCHAR(50) NULL,
        healthBoard         VARCHAR(50) NULL,
        readCodeDescription VARCHAR(250) NULL
    )
"

sql_insert_fhir_hic_biochem = "
    INSERT INTO FHIR_HIC
    (
        subject,
        category,
        code,
        effectiveDate,
        valueQuantity,
        valueUnit,
        valueString,
        referenceRangeHigh,
        referenceRangeLow,
        encounter,
        specimen,
        healthBoard,
        readCodeDescription
    )
    SELECT
        prochi AS subject,
        'Biochemistry' AS category,
        readcodevalue AS code,
        datetimesampled AS effectiveDate,
        (case when (QuantityValue is null and substring(Interpretation, 1, 1)='>') or (QuantityValue is null and substring(Interpretation, 1, 1)='<') 
                 then substring(Interpretation, 2, LENGTH(Interpretation)-1)
              else QuantityValue 
         end
        )AS valueQuantity,
        quantityunit AS valueUnit,
        (case when ArithmeticComparator is not null and ArithmeticComparator!='' 
                 then CONCAT(ArithmeticComparator, QuantityValue, ' ', Interpretation) 
                 else Interpretation end
        ) as valueString,
        rangehighvalue AS referenceRangeHigh,
        rangelowvalue AS referenceRangeLow,
        testreportid AS encounter,
        samplename AS specimen,
        hb_extract AS healthBoard,
        readcodedescription AS readCodeDescription
    FROM HIC
"