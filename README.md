# formazione_cm

file READ.me dove spiegherò tutti i vari passaggi che ho applicato per la track3.


STEP 1:

il primo step era un semplice step introduttivo, dove andavo a creare una repo, (questa repo) e un playbook ansible.
Il playbook serviva per la creazione di un registry docker.

STEP 2:

Il secondo step chiedeva di creare dei playbooks che buildavano due container con sistema operativo differenti.
I container dovevano anche avere il servizio SSH sempre attivo e uno dei due doveva avere permessi Sudo.

per svolgere questo step ho creato inanzitutto due playbook di build che successivamente tramite opzione import_playbook sono stati implementati all'interno di un altro playbook.
build-all.yml.
NB: i playbook hanno creato delle cartelle dove andavano ad inserire le chiavi e i Dockerfile,ora quei container sono stati eliminati.

STEP 3:

Per lo step 3, bisognava creare più ruoli che svolgevano diverse operazioni:
-- build di almeno 2 container
-- creazione e configurazione di un registry
-- push delle build sul registry

io ho creato tre ruoli, tutti presenti nella cartella roles. I roles permettevano tutte le operazioni dello step3, vado a spiegare ogni role partendo dal primo.
container_build:
nel container build ci sono 3 sotto cartelle : defaults, tasks, templates.
in defaults sono state dichiarate all'interno del file main.yml le variabili che poi sono state utilizzate.
in tasks sono presenti sia il file build_container.yml che il file main.yml. Il main.yml prende con include_tasks il file build_container.yml e viene eseguito con una condizione di loop.
Questo permette la creazione dei container.
Andiamo ora a vedere la cartella templates.
la cartella templates contiene i due Dockerfile e uno script chiamato start.sh.j2
sono tutti file scritti in jinja, per permettere all'ambiente di essere dinamico e riutilizzabile (Non conoscendo benissimo la sintassi jinja mi sono aiutato con degli LLM)
Il file utilizzato è il Dockerfile.j2, file che permette la creazione di diverse distribuzioni linux, installazione di pacchetti per ogni container e generazioni di chiavi SSH.

passiamo ora a vedere il container_deploy.
Il container Deploy possiede defaults con all'interno il file main.yml che va a dichiarare le variabili utilizzate dal deploy e successivamente ha anche tasks, con il main.yml e il deploy_container.yml.
Il deploy_container.yml permette varie task:
rimuove vecchi container.
scarica l'immagine dal registry
e successivamente avvia il container.
e si accerta che SSH sia presente all'interno del container.

Infine abbiamo il role container_registry che utilizza la stessa composizione di sotto cartelle ma adesso il file all'interno delle tasks si trova un singolo file che crea il volumeper il registry, stoppa il registry se presente e successivamente lo avvia.

STEP 4:

Lo step richiede semplicemente di utilizzare il vault ansible per oscurare le password.
Quindi ho creato un file secrets.yml , modificato i file deploy-complete e ed entrambi i file build presenti nei roles.
La modifica che è stata applicata all'interno del file deploy-complete è l'inserimento di vars_files: secrets.yml 
mentre all'interno di dei file build e deploy sono stati aggiunti tasks di login con ovviamente credenziali vault.

STEP 5:

Lo step 5 richiedeva un container con il servizio Docker attivo. Ho quindi aggiornato il file presente in defaults in modo che installi docker, cosi il servizio era attivo all'interno del container.
Lo step dopo il container con docker all'interno, chiedeva di creare una pipeline che permetteva di eseguire una build e taggarla in modo progressivo e dopo aver fatto la build pusharla sul registro.
Quindi ho creato la pipeline, che inizialmente mi dava problemi con il jenkins master avendo inserito come hosts all'interno della pipeline "any", dava problemi con il daemon docker, quindi ho riutilizzato l'agent creato per la track2 che possedeva Docker funzionante all'interno e così facendo la pipeline è andata a buon fine.

 

