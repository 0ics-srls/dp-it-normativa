-- the Akoma Ntoso text is kept out of line and uncompressed so substr() slices read only the needed chunks
SELECT attstorage = 'e' AS ok FROM pg_attribute WHERE attrelid = 'akn_documents'::regclass AND attname = 'xml'
