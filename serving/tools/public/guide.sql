SELECT '# Guida ricerca e navigazione — corpus normativo italiano

## Cosa c''è
Il corpus contiene il testo vigente della normativa italiana, spezzato in unità (comma per comma).
Ogni unità ha un URN:NIR citabile e un link Normattiva. La ricerca è il punto d''ingresso: trova,
poi naviga per URN. Per scoprire quali atti ci sono usa `it-normativa_acts_find` (titolo) e `it-normativa_ingest_status` (conteggi per collezione).

## Anatomia URN
`urn:nir:stato:legge:1970-05-20;300~art18-com1`
- atto = tutto prima di `~`  → `urn:nir:stato:legge:1970-05-20;300`
- articolo = fino a `-com`    → `urn:...;300~art18`
- comma = URN completo        → `urn:...;300~art18-com1`

## Come cercare
Lo strumento `it-normativa_search` espone tre modi (parametro `mode`: hybrid|lexical|semantic; default hybrid).

Lessicale (`query`, sintassi websearch):
- `"frase esatta"` tra virgolette
- `parola OR parola` per l''alternativa
- `-parola` per escludere
- più parole = AND implicito

Lessicale avanzato (`lexical_raw`, sintassi to_tsquery):
- prefisso: `term:*` (es. `licenz:*` → licenziamento, licenziare)
- distanza: `a <N> b` (le parole a distanza esatta N)
- booleani: `&` (e), `|` (o), `!` (non)
- sintassi malformata → errore, non un risultato vuoto silenzioso

Semantica: ricerca per significato sull''embedding (mode=semantic), utile quando non conosci i termini esatti.
Se il servizio di embedding non è disponibile la ricerca ibrida torna solo il lessicale e la risposta porta un avviso.

Filtri secchi (combinabili, in AND): `collection`, `act` (URN base dell''atto), `article_num`,
`date_from`, `date_to` (ISO yyyy-MM-dd). Senza `query`/`lexical_raw` diventa un elenco filtrato per URN.
`k` = numero massimo di risultati (1..50, cap rigido).

## Navigazione
`it-normativa_search` è l''ingresso; tutto il resto naviga per URN:
- `it-normativa_act_outline` (urn atto) → indice articoli in ordine giuridico (2, 2-bis, 5, 10), paginato con limit/offset
- `it-normativa_article` (urn articolo) → l''articolo con i suoi commi
- `it-normativa_comma` (urn comma) → il testo citabile verbatim
- `it-normativa_version_at_date` (urn + data) → versione storica se disponibile (`supported`)
- `it-normativa_refs` (urn) → i rinvii uscenti
- `it-normativa_act_akn` (urn atto) → l''XML Akoma Ntoso a fette: richiama con `offset` = `next_offset` finché è NULL
- `it-normativa_act_versions` (urn atto) → le date in cui il testo è cambiato
- `it-normativa_guide` → questa guida

## Flussi
- Citazione: `it-normativa_search` → `it-normativa_act_outline` → `it-normativa_comma` (verifica il testo prima di citare)
- Time-travel: `it-normativa_search` → `it-normativa_version_at_date` per la formulazione a una certa data
- Esplora atto: `it-normativa_acts_find` → `it-normativa_act_outline` (pagina con offset) → `it-normativa_article`

## Limiti
- `k` ≤ 50; outline `limit` ≤ 200
- `it-normativa_refs` restituisce `graph_populated` = false: il grafo dei rinvii non è popolato e una lista vuota non è prova di assenza
- `it-normativa_version_at_date` con `supported` = false: è conservata solo la versione vigente
- risposte molto lunghe vengono troncate (avviso `max_bytes`): usa le fette di `it-normativa_act_akn`' AS text
