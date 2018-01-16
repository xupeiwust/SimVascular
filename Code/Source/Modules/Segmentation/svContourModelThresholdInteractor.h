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

#ifndef SVCONTOURMODELTHRESHOLDINTERACTOR_H
#define SVCONTOURMODELTHRESHOLDINTERACTOR_H

#include "SimVascular.h"

#include <svSegmentationExports.h>

#include "svContourModel.h"
#include "svContourGroupDataInteractor.h"

#include <itkEventObject.h>
#include <mitkInteractionPositionEvent.h>

class SVSEGMENTATION_EXPORT svContourModelThresholdInteractor : public mitk::DataInteractor
{
public:
    mitkClassMacro(svContourModelThresholdInteractor, mitk::DataInteractor);
    itkFactorylessNewMacro(Self)
    itkCloneMacro(Self)

    void SetScaleBase(double scaleBase);

    double GetCurrentValue();

    void SetPathPoint(svPathElement::svPathPoint pathPoint) {m_PathPoint=pathPoint;}

    svPathElement::svPathPoint GetPathPoint() {return m_PathPoint;}

    vtkImageData* GetVtkImageData() {return m_VtkImageData;}

    void SetVtkImageData(vtkImageData* imageData) {m_VtkImageData=imageData;}

    void SetResliceSize(double size) {m_ResliceSize=size;}

    void SetGroupInteractor(svContourGroupDataInteractor::Pointer groupInteractor) {m_GroupInteractor=groupInteractor;}

protected:

    svContourModelThresholdInteractor();
    virtual ~svContourModelThresholdInteractor();

    virtual void ConnectActionsAndFunctions() override;

    //  Conditions //

    bool OnCurrentContourPlane( const mitk::InteractionEvent* interactionEvent );

    bool AtValidLocation( const mitk::InteractionEvent* interactionEvent );

    //  Actions //

    void StartDrawing(mitk::StateMachineAction*, mitk::InteractionEvent* interactionEvent);

    void UpdateDrawing(mitk::StateMachineAction*, mitk::InteractionEvent* interactionEvent);

    void FinishDrawing(mitk::StateMachineAction*, mitk::InteractionEvent* interactionEvent );

    void ClearDrawing(mitk::StateMachineAction*, mitk::InteractionEvent* interactionEvent );

private:

    svContour* m_Contour;

    mitk::Point3D m_LastPoint;

    double m_MinValue;

    double m_MaxValue;

    double m_CurrentValue;

    int m_TimeStep;

    double m_ScaleBase;// use display units

    std::string m_Method;

    vtkImageData* m_VtkImageData;

    vtkImageData* m_ImageSlice;

    double m_ResliceSize;

    svPathElement::svPathPoint m_PathPoint;

    svContourGroupDataInteractor::Pointer m_GroupInteractor;

};

itkEventMacro( EndInteractionContourModelEvent, svContourModelEvent );
itkEventMacro( UpdateInteractionContourModelEvent, svContourModelEvent );

#endif // SVCONTOURMODELTHRESHOLDINTERACTOR_H
