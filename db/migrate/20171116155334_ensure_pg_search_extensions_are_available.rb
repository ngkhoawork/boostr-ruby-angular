class EnsurePgSearchExtensionsAreAvailable < ActiveRecord::Migration
  def up
    # pg_trgm
    execute 'CREATE EXTENSION IF NOT EXISTS pg_trgm;'

    # fuzzystrmatch
    execute 'CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;'
    say_with_time("Adding support functions for pg_search :dmetaphone") do
      execute <<-'SQL'
CREATE OR REPLACE FUNCTION pg_search_dmetaphone(text) RETURNS text LANGUAGE SQL IMMUTABLE STRICT AS $function$
  SELECT array_to_string(ARRAY(SELECT dmetaphone(unnest(regexp_split_to_array($1, E'\\s+')))), ' ')
$function$;
      SQL
    end
  end

  def down
    # pg_trgm
    execute 'DROP EXTENSION IF EXISTS pg_trgm;'

    # fuzzystrmatch
    execute 'DROP EXTENSION IF EXISTS fuzzystrmatch;'
    say_with_time("Dropping support functions for pg_search :dmetaphone") do
      execute <<-'SQL'
DROP FUNCTION pg_search_dmetaphone(text);
      SQL
    end
  end
end
