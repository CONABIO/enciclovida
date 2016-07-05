module Ancestry
  # Setting the pattern this way silences the warning when
  # we overwrite a constant
  send :remove_const, :ANCESTRY_PATTERN
  ### /\A[0-9]+(\/[0-9]+)*\Z/
  const_set :ANCESTRY_PATTERN, /\A[0-9a-z]+(\/[0-9a-z]+)*\Z/
end