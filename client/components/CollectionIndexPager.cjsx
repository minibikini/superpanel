ReactPager = require 'react-pager'

module.exports = CollectionIndexPager = ({totalPages, currentPage, visiblePages, onChange}) ->
  return <div /> unless totalPages

  <ReactPager
    total={totalPages}
    current={currentPage}
    titles={{
      first:   'First',
      prev:    '\u00AB',
      prevSet: '...',
      nextSet: '...',
      next:    '\u00BB',
      last:    'Last'
    }}
    visiblePages={visiblePages}
    onPageChanged={onChange}
  />

CollectionIndexPager.displayName = 'CollectionIndexPager'