CSV_DOWNLOAD_PAGE_URL = "http://nppes.viva-it.com/NPI_Files.html"
TAXONOMY_ROOT = "http://www.nucc.org"
TAXONOMY_CSV_DOWNLOAD_PAGE_URL = File.join(TAXONOMY_ROOT, "index.php?option=com_content&view=article&id=107&Itemid=132")

ROOT                  = File.expand_path("../", __FILE__)

TMP_ROOT              = File.join(ROOT, "tmp")
DATA_ROOT             = File.join(ROOT, "data")
OUT_DIR               = File.join(ROOT, "out")
LOG_ROOT              = File.join(ROOT, "log")
DOC_ROOT              = File.join(ROOT, "doc")

ZIP_FILE_NAME         = 'npi_data.zip'
CSV_FILE_NAME         = 'npi_data.csv'
HEADER_FILE_NAME      = 'npi_data_header.csv'

TAX_CSV_FILE_NAME     = "taxonomies.csv"
TAX_JSON_FILE_NAME    = "taxonomies.json"

ZIP_SOURCE            = File.join TMP_ROOT, ZIP_FILE_NAME
CSV_SOURCE            = File.join TMP_ROOT, CSV_FILE_NAME
HEADER_SOURCE         = File.join TMP_ROOT, HEADER_FILE_NAME
TAX_SOURCE            = File.join TMP_ROOT, TAX_CSV_FILE_NAME

CSV_DESTINATION       = File.join DATA_ROOT, CSV_FILE_NAME
HEADER_DESTINATION    = File.join DATA_ROOT, HEADER_FILE_NAME
TAX_DESTINATION       = File.join DATA_ROOT, TAX_JSON_FILE_NAME

SAMPLE_SIZE           = 20_000

DATA_FILE_LENGTH      = `wc -l #{CSV_DESTINATION}`.split[0].to_i

PROCESSES             = 4
FILE_CHUNK_DEST       = File.join(TMP_ROOT, "npi_data")
FILE_CHUNK_PREFIX     = File.join(FILE_CHUNK_DEST, "npi_data_")

FILE_CHUNK_SIZE       = if DATA_FILE_LENGTH % PROCESSES == 0
                          DATA_FILE_LENGTH / PROCESSES
                        else
                          DATA_FILE_LENGTH / (PROCESSES - 1)
                        end

TRANSFORM_COMMAND     = "./bin/transform"

# ES_URL                = "https://p85r5xdj:rdpoxxikk9s0357e@oak-7316449.us-east-1.bonsai.io/"
ES_URL                = "http://localhost:9200"

ES_INDEX_NAME         = "dctrs"
GZIP_REQUEST_BODY     = true
