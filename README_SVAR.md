# Oppgave 1
1A - Containerisering
Jeg har laget en multi stage Dockerfile med to steg. Først brukes Maven og Java 21 til å bygge Spring Boot applikasjonen til en JAR-fil. Deretter brukes Java 21 JRE til å kjøre applikasjonen. Dette gir et mindre Docker image uten unødvendige byggeverktøy. 

Jeg har bygget og testet Dockerimaget lokalt med følgende kommandoer:
docker build -t wishifai:lokal .
docker run --name wishifai-test -p 9999:8080 wishifai:lokal

Port 9999 på vertsmaskinen kobles til port 8080 inne i containeren. Jeg kontrollerte at Spring Boot startet ved å kalle /actuator/health, som returnerte HTTP 200 med status UP.
Jeg har publisert dockerimaget til Docker Hub for at det kan hentes og kjøres uten å ha tilgang til mitt lokal image.
https://hub.docker.com/r/huriyet/wishifai

Imaget kan hentes og startes med:

docker pull huriyet/wishifai:latest
docker run --rm -p 9999:8080 huriyet/wishifai:latest

Jeg har testet det publiserte imaget med:
curl http://localhost:9999/actuator/health

Dette returnerte status UP, som bekrefter at applikasjonen starter og svarer på helsesjekken. 

1B - CI- Pipeline
Jeg har satt opp en GitHub Actions-workflow i .github/workflows/ci.yml for å automatisere bygging og publisering av Docker-imaget til AWS elastic container registry.

Workflowen starter automatisk når jeg pusher endringer til main. Den henter prosjektkoden, konfigurerer AWS tilgang, logger inn i ECR, bygger Docker-imaget og publiserer det til repositoryet wishifai-41.

Jeg bruker Git-commit-SHA som image tag for å kunne spore versjoner og enklere rulle tilbake ved feil. 
AWS tilgangsnøkkelene er lagret som Github action secrets (AWS_ACCESS_KEY_ID og AWS_SECRET_ACCESS_KEY), slik at de ikke ligger direkte i workflow-filen.

https://github.com/HNIYAZ729/PGR301-Exam-Wishifai/actions/runs/42224940263

## Oppgave 2
2A - Jeg har brukt Terraform til å opprette en ECS Express tjeneste og en S3 bucket: wishifai-images-41.
ECS kjører Docker-imaget fra ECR. Jeg har opprettet en IAM task role som gir applikasjonen nødvendige AWS-tillatelser. S3-bucketen settes automatisk som miljøvariabel.

I Terraform har jeg definert tre variabler: aws_region med verdien eu-north-1, candidate_number med verdien 41, og image_tag som angir hvilken versjon av Docker-imaget som skal brukes. Jeg har også definert en output kalt wishifai_url, som viser den offentlige URL-en til ECS applikasjonen. 

https://wi-914d13c45531484794577969ae42efeb.ecs.eu-north-1.on.aws

2B - Remote State
Jeg lagrer Terraform State i S3 i stedet for lokalt.
* Bucket: pgr301-terraform-state
* Nøkkel: wishifai/41/terraform.tfstate

Dette gjør at flere utviklere kan bruke samme Terrefom State

2C - Terraform i GitHub Actions

Jeg har konfigurert Github Actions slik at Terraform kjører etter at Docker-imaget er bygget og publisert til ECR. Dette sikrer at imaget er tilgjengelig før ECS tjenesten oppdateres. Terraform bruker samme Git-commit-SHA som image-tag, slik at jeg kan se hvilken versjon som er distribuert. Jeg har valgt å automatisere denne prosessen for å redusere manuelt arbeid og risikoen for feil ved deployment. 

Pipelinen kjører terraform fmt -check for å kontrollere formateringen av Terraform-filene. Hvis filene ikke er riktig formatert, feiler dette steget i pipelinen. Terraform bruker også needs: build, slik at deployment først starter når build er fullført. 

https://github.com/HNIYAZ729/PGR301-Exam-Wishifai/actions/runs/42224940263

### Oppgave 3
3A - Jeg har brukt Micrometer til å implementere to timere som måler hvor lang tid AWS Rekognition og Bedrock bruker på å svare. Disse heter wishifai.rekognition.duration og wishifai.bedrock.duration. 

Jeg valgte disse timerne fordi oppgaven handler om å finne ut hvorfor applikasjonen svarer langtsomt. Ved å sammenligne responstidene kan jeg undersøke om det er bildeanalysen i Rekognition eller genereringen av gaveforslag i Bedrock som bruker mest tid. Målingene fra 9.november viste at Rekognition brukte 1,4-1,6 sekunder, mens Bedrock brukte 14-16 sekunder. Bedrock var dermed den største flaskehalsen og brukte omtrent ti ganger så lang tid som Rekognition. 

Jeg har også implementert en business metrikk som teller antall bildeanalyseforsøk. Jeg valgte denne fordi den viser hvor mye tjenesten brukes, og kan bidra til å oppdage uvanlig høy aktivitet.

Micrometer sender målingene til Cloudwatch hvert minutt. For å forbedre responstiden vill jeg undersøkt om en kortere prompt, færre genererte tokens eller en raskere Bedrock modell kunne redusere tiden det tar å generere gaveforslag. 

3B - Jeg har opprettet et Cloudwatch-dashboard med Terraform. Dashbordet viser tre typer metrikker: en business-metrikk som teller antall bildeanalyseforsøk, en infrastrukturmetrikk som viser CPU-bruk i ECS, og en applikasjonsmetrikk som viser JVM-minnebruk. 

Jeg har også opprettet en alarm som utløses dersom antall bildeanalyseforsøk overstiger 20 i løpet av fem minutter. Jeg valgte denne grensen for å oppdage uvanlig høy aktivitet, som kan føre til økt belastning og flere AWS-kall. Grensen er foreløpig og bør justeres basert på faktisk bruk. 

Til slutt kontrollerte jeg at dashbordet viste målinger, og at alarmen hadde status OK. 

Cloudwatch Dashbord: wishifai-41-dashboard
Cloudwatch Alarm: wishifai-41-analysis-alarm

#### Oppgave 4

Gjennom arbeidet med Wishifai har jeg erfart at en applikasjon kan fungere teknisk uten at resultatene er nødvendigvis riktige. Wishifai bruker Amazon Rekognition til å analysere bilder og Amazon Bedrock til å generere gaveforslag. At systemet svarer uten feil, betyr likevel ikke at forslagene passer til mottakeren. Testing, kontinuerlig leveranse og overvåkning må derfor tilpasses både generativ AI og risikoen ved bruksområdet. 

Tradisjonelle tester sammenligner ofte resultatet med et forventet svar, men en LLM kan gi ulike svar på samme input. Vi må derfor også teste egenskaper ved svaret, ikke bare eksakte svar. For wishifai kunne jeg laget et eval-sett med faste testbilder, for eksempel et barnerom og en garasje. Kravet kunne være at forslagene henger sammen med bildet og ikke er farlige for barn. Testene kan kjøres i CI/CD-pipeline ved hver endring av prompt eller modell, gjerne vurdert av en annen LLM, og deployen stoppes hvis for mange tester feiler. Automatiske tester fanger likevel ikke alt, så et utvalg svar bør i tillegg vurderes manuelt. 

Dette henger tett sammen med kontinuerlig leveranse, fordi vi med generativ AI ikke bare deployer kode. Prompt, systemprompt og modellversjon kan endres uavhengig av koden, og selv små endringer kan påvirke resultatene. Disse bør derfor versjoneres i Git, og modell-ID-en i Bedrock bør være tydelig angitt. Da vet vi hva som kjører, og vi kan rulle tilbake dersom en endring gir dårligere svar. Nye versjoner kan testes på en liten gruppe brukere gjennom canary deployment eller feature flags.

Selv med gode tester og en kontrollert utrulling kan kvaliteten svekkes i produksjon, og her blir overvåkning viktig. I oppgave 3 laget jeg et CloudWatch-dashbord som viser antall bildeanalyser, CPU-bruk i ECS og JVM-minnebruk. Jeg laget også en alarm for uvanlig høy aktivitet. Dette viser om systemet kjører, men alarmen ville ikke reagert om Bedrock begynt å foreslå upassende gaver. Jeg ville derfor også overvåket tokenforbruk, kostnad, avviste forespørsler og tilbakemeldinger fra brukerne. Endringer i disse målingene kan være tegn på at kvaliteten blir dårligere og at det er problemer som bør undersøkes. 

Hvor strenge kravene bør være, avhenger av konsekvensene av feil. I wishifai påvirker et dårlig gaveforslag først og fremst brukeropplevelsen, men upassende forslag bør helst oppdages før produksjon. I en bank der rådgivere bruker AI, kan feil råd derimot føre til økonomisk tap for kunden. Der bør kravene til testing bør være strengere, og at mennesker bør godkjenne viktige endringer før produksjon. Relevante beslutninger bør også dokumenteres slik at de kan etterprøves, samtidig som personvernet ivaretas. 

Hensikten med AI er blant annet å effektivisere arbeidet, men det må ikke gå på bekostning av sikkerhet. DevOps for AI handler derfor om å la risikoen styre hvor grundig vi tester, hvor raskt endringer rulles ut og hvor mye menneskelig kontroll som er nødvendig. 

