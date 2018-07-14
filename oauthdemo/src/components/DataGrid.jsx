import React, { Component } from 'react';
import './datagrid.css';

const TableSection = ({ data, metadata }) => {
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
                <th colSpan="4">{data.length} RECORDS</th>
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

const TableHeader = ({ metadata }) => metadata.map(colMetaDataHeader => <HeaderRow metadata={colMetaDataHeader} key={colMetaDataHeader.name} />);
const HeaderRow = ({ metadata }) => (
  <th>{metadata.name}</th>
);

const TableBody = ({ tableData, metadata }) => {
  if (!tableData) {
    return null;
  }
  return tableData.map(rowData => <Row data={rowData} metadata={metadata} key={rowData.companyId} />);
};

const Row = ({ data, metadata }) => (
  <tr>
    {metadata.map(colMetaData => <RowColumn value={data[colMetaData.key]} key={colMetaData.key} />)}
  </tr>
);

const RowColumn = ({ value }) => (
  <td>{value}</td>
);

class DataGrid extends Component {

  render() {
    return <TableSection data={this.props.data} metadata={this.props.metadata} />;
  }
}


export default DataGrid;
