1. Añadir README.md al repo
2. Fusionar los guiones air_* ya que sus diferencias son mínimas, supongo que se pueden parametrizar:
14c14
< rows = session.execute('SELECT "Published Airline", "Published Airline IATA Code", "Terminal", "Boarding Area", "Passenger Count", "Month", "Year", "GEO Region", "Price Category Code", "Activity Type Code" FROM air_traffic WHERE "Published Airline" = \'Air Berlin\' AND "Boarding Area" = \'G\' ALLOW FILTERING;')
---
> rows = session.execute('SELECT "Published Airline", "Published Airline IATA Code", "Terminal", "Boarding Area", "Passenger Count", "Month", "Year", "GEO Region", "Price Category Code", "Activity Type Code" FROM air_traffic WHERE "Operating Airline" = \'Air China\' ALLOW FILTERING;')
21c21
< print('##############################  Recuperar todos los vuelos de la compañía “AirBerlín”embarcados porla puerta “G” ##############################')
---
> print('##############################   Recuperar todos los registros de la aerolínea “Air China”   ##############################')
23d22
< 
3. Sigo mirando
