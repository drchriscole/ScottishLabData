##
## Utility functions
##

createFhirTable <- function(table_name = 'FHIR') {
    stmt = sprintf("
CREATE TABLE %s (
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
                   ", table_name)
    return(stmt)
}

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

sql_create_fhir_dash = createFhirTable("FHIR_DaSH")

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

sql_create_fhir_glasgow = createFhirTable("FHIR_Glasgow")

sql_insert_fhir_glasgow = "
    INSERT INTO FHIR_Glasgow
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
        discipline AS category,
        clinicalcodevalue AS code,
        substr(sampledate, 1, 10) AS effectiveDate,
        quantityvalue AS valueQuantity,
        quantityunit AS valueUnit,
        (case when ARITHMETICCOMPARATOR != '' 
    	     then CONCAT(ARITHMETICCOMPARATOR, QUANTITYVALUE) 
    		 else null 
    		 end
    	) as valueString,
        rangehighvalue AS referenceRangeHigh,
        rangelowvalue AS referenceRangeLow,
        testid AS encounter,
        samplename AS specimen,
        'Glasgow' AS healthBoard,
        clinicalcodedescription AS readCodeDescription
    FROM Glasgow
"

sql_create_fhir_hic = createFhirTable("FHIR_HIC")

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

sql_create_lothian_readcode = "
    CREATE TABLE Lothian_ReadCode As
        SELECT * FROM 
            (
              SELECT DISTINCT * FROM Lothian
            ) b
        INNER JOIN 
            (
              SELECT DISTINCT Test_Code, Read_Code FROM Lothian_TestCode2ReadCode
             ) lkp
        ON b.TestItemCode = lkp.Test_Code
"

sql_create_fhir_lothian = createFhirTable('FHIR_Lothian')

sql_insert_fhir_lothian = "
    INSERT INTO FHIR_Lothian
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
        '' AS category,
        Read_Code AS code,
        SpecimenCollectionDate AS effectiveDate,
        (case when Value/1 != 0 
                 then Value 
              when substring(Value, 1, 1)='>' or substring(value, 1, 1)='<'
                 then substring(Value, 2, LENGTH(Value)-1)
              else NULL 
         end
         ) AS valueQuantity,
        Unit AS valueUnit,
        Value AS valueString,
        (case when RangeMax/1 != 0 
                 then RangeMax 
              else NULL 
         end
        ) AS referenceRangeHigh,
        (case when RangeMin/1 != 0 
                 then RangeMin 
              else NULL 
         end
        ) AS referenceRangeLow,
        0 AS encounter,
        '' AS specimen,
        'Lothian' AS healthboard,
        TestItem AS readcodedescription
    FROM Lothian_ReadCode
"