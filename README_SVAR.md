Oppgave 1
1A - Containerisering
Jeg har laget en multi-stage Dockerfile med to steg. Først brukes Maven og Java 21 til å bygge Spring Boot applikasjonen til en JAR-fil. 
Deretter brukes Java 21 JRE til å kjøre applikasjonen. dette gir mindre Docker.image uten unødvendige byggeverktøy.

Jeg har bygget og testet Docker-imaget lokalt med følgende kommandoer:
docker build -t wishifai:lokal .
docker run --name wishifai-test -p 9999:8080 wishifai_lokal

port 9999 på vertsmaskinen kobles til port 8080 inne i containeren. Jeg kontrollerte at spring boot applikasjonen startet ved å kalle /actuator/health, som returnerte HTTP 200 med status UP.

1B - CI- Pipeline
Jeg har satt opp en GitHub Actions-workflow i .github/workflow/ci.yml for å automatisere bygging og publisering av Docker-imaget til AWS elastic container registry.

Workflowen starter automatisk når jeg pusher endringer til main. Den heter prosjektkoden, konfigurerer AWS tilgang, logger inn i ECR, gybber Docker-imaget og publiserer det til repositoryet wishifai-41.

Jeg bruker Git-commit-SHA som image tag for å kunne spore versjoner og enklere rulle tilbake ved feil. 
AWS tilgangsnøkkelene er lagret som Github action secrets (AWS_ACCESS_KEY_ID og AWS_SECRET_ACCESS_KEY), slik at de ikke ligger direkte i workflow-filen.

https://github.com/HNIYAZ729/PGR301-Exam-Wishifai/actions/runs/42224940263

Oppgave 2
1A - ECS Express og Terraform
Jeg har brukt Terraform til å opprette en ECS Express tjeneste og en S3 bucket (wishifai-images-41).

ECS kjører Docker-imaget fra ECR. Jeg har opprettet en IAM Task Role som gir applikasjonene nødvendige AWS-tillatelser. 
S3 bucketen settes automatisk som miljøvariabel.

https://wi-914d13c45531484794577969ae42efeb.ecs.eu-north-1.on.aws

2B - Remote State
Jeg lagrer Terraform State i S3 i stedet for lokalt.
* Bucket: pgr301-terraform-state
* Nøkkel: wishifai/41/terraform.tfstate

Dette gjør at flere utviklere kan bruke samme Tarrefom State

2C - Terraform i GitHub Actions

Jeg har konfigurert Github Actions slik at Terraform kjører etter at Docker-imaget er bygget og publisert til ECR.
Dette sikret at imaget er tilgjengelig før ECS oppdateres. Terraform bruker samme Git-commit-SHA ved deployment.

https://github.com/HNIYAZ729/PGR301-Exam-Wishifai/actions/runs/42224940263
