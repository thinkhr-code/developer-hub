import React, { Component } from 'react';
import './datagrid.css';

const TableSection = ({ typeName, data, metadata }) => {
  if (!data || !data.length) {
    return null;
  }
  return (
    <div className="data-grid">
      <div className="content">
        <div className="table">
          <table>
            <thead>
              <tr className="total-record-row">
                <th colSpan={metadata.length}>{data.length} {typeName}RECORDS</th>
              </tr>
              <tr className="table-header">
                <TableHeader metadata={metadata} />
              </tr>
            </thead>
            <tbody>
              <TableBody tableData={data} metadata={metadata} />
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

const TableHeader = ({ metadata }) => metadata.map(colMetaDataHeader => (<HeaderRow
  metadata={colMetaDataHeader}
  key={colMetaDataHeader.name}
                                                                         />));
const HeaderRow = ({ metadata }) => (
  <th>{metadata.name}</th>
);

const TableBody = ({ tableData, metadata }) => {
  if (!tableData) {
    return null;
  }
  return tableData.map(rowData => (<Row
    data={rowData}
    metadata={metadata}
    key={rowData.companyId}
                                   />));
};

const Row = ({ data, metadata }) => (
  <tr>
    {metadata.map(colMetaData => (<RowColumn
      value={(data[colMetaData.key])}
      key={colMetaData.key}
                                  />))}
  </tr>
);


const RowColumn = ({ value }) => {

  // Just return the value if it's an integer or it's length is <= 50 characters
  if ( value && ( Number.isInteger( value ) || value.length <= 50 ) ) {
    return (<td>{value}</td>);
  }

  const renderInnerContent = (content) => {
    const e = document.createElement('div');
    e.innerHTML = content;
    return e.childNodes.length === 0 ? '' : e.childNodes[0].nodeValue;
  };

  const keydownEvent = (event) => {
    const key = event.key; // const {key} = event; in ES6+
    if (key === "Escape") {
        closePopup();
    }
  };

  const showColumnPopup = (e) => {
    window.addEventListener('keydown', keydownEvent);
    document.getElementById('popup').style.display = 'block';
    const htmlIframe = document.getElementById('htmlIframe');
    htmlIframe.src = 'about:blank';
    setTimeout(() => {
      htmlIframe.contentWindow.document.write(renderInnerContent(value));
    }, 300);
  };

  const closePopup = () => {
    window.removeEventListener('keydown', keydownEvent);
    document.getElementById('popup').style.display = 'none';
  };

  return (
    <td>
      <div id="popup">
        <div onClick={closePopup} className="closeButton">X</div>
        <div className="popup-data">
          <iframe id="htmlIframe" />
        </div>
      </div>
      <div
        style={{
          textDecoration: 'underline',
          color: 'blue',
        }}
        onClick={showColumnPopup}
      >Details
      </div>
    </td>
  );

};

class DataGrid extends Component {
  render() {
    return (
      <div>
        <TableSection typeName={this.props.typeName} data={this.props.data} metadata={this.props.metadata} />
      </div>
    );
  }
}


export default DataGrid;
