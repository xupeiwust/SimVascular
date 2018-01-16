/* Copyright (c) Stanford University, The Regents of the University of
 *               California, and others.
 *
 * All Rights Reserved.
 *
 * See Copyright-SimVascular.txt for additional details.
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject
 * to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 * IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "svPathPoint2DSizeAction.h"

#include "svPath.h"

#include <mitkNodePredicateDataType.h>

#include <QInputDialog>

svPathPoint2DSizeAction::svPathPoint2DSizeAction()
    : m_Functionality(NULL)
{
}

svPathPoint2DSizeAction::~svPathPoint2DSizeAction()
{
}

void svPathPoint2DSizeAction::Run(const QList<mitk::DataNode::Pointer> &selectedNodes)
{
    mitk::DataNode::Pointer selectedNode = selectedNodes[0];

    mitk::NodePredicateDataType::Pointer isPath = mitk::NodePredicateDataType::New("svPath");

    float initialValue=10.0f;
    if(isPath->CheckNode(selectedNode))
        selectedNode->GetFloatProperty ("point 2D display size", initialValue);

    bool ok;
    float size=QInputDialog::getDouble(NULL, "Point 2D Display Size", "Size:", initialValue, 0.1, 100.0, 1, &ok);

    if(!ok)
        return;

    mitk::DataNode::Pointer pathFolderNode=NULL;
    if(selectedNode.IsNotNull())
    {
        mitk::DataStorage::SetOfObjects::ConstPointer rs = m_DataStorage->GetSources(selectedNode);
        if(rs->size()>0){
            pathFolderNode=rs->GetElement(0);
            if(pathFolderNode.IsNotNull())
                pathFolderNode->SetFloatProperty("point 2D display size",size);
        }
    }

    for(int i=0;i<selectedNodes.size();i++)
    {
        mitk::DataNode::Pointer node = selectedNodes[i];
        if(!isPath->CheckNode(node))
            continue;

        node->SetFloatProperty("point 2D display size",size);
        svPath* path=dynamic_cast<svPath*>(node->GetData());
        if(path)
        {
            path->SetProp("point 2D display size",QString::number(size).toStdString());
            path->SetDataModified();
        }
    }

}

void svPathPoint2DSizeAction::SetDataStorage(mitk::DataStorage *dataStorage)
{
    m_DataStorage = dataStorage;
}

void svPathPoint2DSizeAction::SetFunctionality(berry::QtViewPart *functionality)
{
    m_Functionality=functionality;
}

