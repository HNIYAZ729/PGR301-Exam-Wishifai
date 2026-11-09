Oppgave 1
1A - Containerisering
Jeg har laget en multi stage Dockerfile for wishifai applikasjon, som er utviklet med Java og Spring Boot.
Dockerfile består av 2 steg. I det første steget brukes Marven og Java 21 til å bygge applikasjonen til en JAP-fil. I det andre siste steget brukes Java 21 JRE til å kjøre den ferdige applikasjonen.

Fordelen med multi-stage build er at marven, kildekoden og andre byggeverktøy ikke trenger å være med i det endelige Docker-imaget.
Dette gjør imaget mindre og reduserer antall unødvendige komponenter.

Jeg har bygget og testet Docker-imaget lokalt med følgende kommandoer:
docker build -t wishifai:lokal .
docker run --name wishifai-test -p 9999:8080 wishifai_lokal

port 9999 på vertsmaskinen kobles til port 8080 inne i containeren. Jeg kontrollerte at spring boot applikasjonen startet ved å kalle /actuator/health, som returnerte HTTP 200 med status UP.

1B - CI- Pipeline
Jeg har satt opp en GitHub Actions-workflow i .github/workflow/ci.yml for å automatisere bygging og publisering av Docker-imaget til AWS elastic container registry.

Workflowen starter automatisk når jeg pusher endringer til main. Den heter prosjektkoden, konfigurerer AWS tilgang, logger inn i ECR, gybber Docker-imaget og publiserer det til repositoryet wishifai-41.

Jeg har valgt å bruke Git-commit-SHA som image tag i stedet for bare latest. Dette gjør det mulig å identifisere hvilken versjon av kildekoden et Docker-imaget er byggget fra, og gjør det enklere å spore versjoner ved feil eller behov for tilbakerulling.

AWS tilgangsnøkkelene er lagret som Github action secrets (AWS_ACCESS_KEY_ID og AWS_SECRET_ACCESS_KEY), slik at de ikke ligger direkte i workflow-filen.

jeg har testet workflowen ved å pushe endringer til main. Github actions fullførte kjøringen uten feil, og jeg bekrefter at docker-imaget ble publisert til AWS ECR med commit-SHA som tag.

https://github.com/HNIYAZ729/PGR301-Exam-Wishifai/actions/runs/42224940263
